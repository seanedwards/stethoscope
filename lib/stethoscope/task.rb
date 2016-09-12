module Stethoscope
  class Task
    attr_reader :deadline
    attr_reader :block

    def initialize(time_offset, &block)
      @deadline = DateTime.now + time_offset
      @block = block
    end
  end
end
