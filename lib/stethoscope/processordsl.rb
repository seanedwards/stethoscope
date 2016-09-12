require 'docile'

module Stethoscope
  class ProcessorDSL
    def initialize(processor, file, &block)
      @processor = processor
      Docile.dsl_eval(self) do
        instance_eval &block if block
        instance_eval File.read(file), file
      end
    end

    def on_event(name, &block)
      @processor.responders[name] = block
    end

    def on_interrupt(&block)
      @processor.on_interrupt &block
    end
  end
end
