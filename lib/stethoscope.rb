require "stethoscope/version"
require 'date'
require 'pqueue'
require 'cri'
require 'active_support/time'

module Stethoscope
  STATSD_REGEX = /(?<event_name>.+):(?<event_value>\d+)\|(?<event_type>.+)(|(?<sample_rate>.+))?/

  CLI = Cri::Command.define do
    name 'stethoscope'
    usage 'stethoscope <file>'
    flag  :h, 'help',  'show help for this command' do |value, cmd|
      puts cmd.help
      exit 0
    end

    run do |options, args, cmd|
      unless file = args.first
        puts cmd.help
        exit 1
      end

      processor = Processor.new
      dsl = ProcessorDSL.new(processor, file)

      buffer = StringIO.new
      begin
        while true
          begin
            $stdin.read_nonblock(512).split('\n').each do |line|
              processor.process line
            end
          rescue IO::WaitReadable
            processor.process
          end
          sleep 0
        end
      rescue Interrupt
        processor.interrupt
      end
    end
  end

  def self.main(args)
    CLI.run(args)
  end
end

require 'stethoscope/task'
require 'stethoscope/processor'
require 'stethoscope/processordsl'

