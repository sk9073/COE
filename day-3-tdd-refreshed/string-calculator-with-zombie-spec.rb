require_relative 'string-calculator-with-zombie'

describe StringCalculator do
  it 'returns 0 for an empty string' do
    expect(StringCalculator.new.add('')).to eq(0)
  end
end
