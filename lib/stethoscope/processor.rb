module Stethoscope
  class Processor
    attr_reader :responders

    def initialize
      @in_tasks = PQueue.new { |a, b| a.deadline < b.deadline }
      @responders = {}
    end

    def task_in(time_offset, &block)
      @in_tasks.push Task.new(time_offset, &block)
    end

    def on_interrupt(&block)
      @interrupt_handler = block
    end

    def process(line = nil)
      if line
        event_data = Stethoscope::STATSD_REGEX.match(line)

        if responder = responders[event_data[:event_name]]
          Docile.dsl_eval(self, event_data, &responder)
        end
      end

      while !@in_tasks.empty? && @in_tasks.top.deadline <= DateTime.now
        top = @in_tasks.pop
        self.instance_eval(&top.block)
      end
    end

    def interrupt
      Docile.dsl_eval(self, &@interrupt_handler) if @interrupt_handler
    end
  end

end
