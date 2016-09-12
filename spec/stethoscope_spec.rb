require 'spec_helper'

describe Stethoscope do
  it 'has a version number' do
    expect(Stethoscope::VERSION).not_to be nil
  end

  it 'processes' do
    processor = Stethoscope::Processor.new
    receiver_zero = double()
    receiver_one = double()

    processor.in 1.seconds do
      receiver_one.one
    end
    processor.in 0.seconds do
      receiver_zero.zero
    end

    expect(receiver_zero).to receive(:zero)
    processor.process

    sleep 1

    expect(receiver_one).to receive(:one)
    processor.process
  end
end
