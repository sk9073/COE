require_relative 'string-calculator-with-zombie'

describe StringCalculator do
  it 'returns 0 for an empty string' do
    expect(StringCalculator.new.add('')).to eq(0)
  end

  it 'returns sum of given input numbers' do
    expect(StringCalculator.new.add('1')).to eq(1)
    expect(StringCalculator.new.add('1,2')).to eq(3)
  end

  it 'allows new lines between numbers instead of commas' do
    expect(StringCalculator.new.add("1\n2,3")).to eq(6)
  end
end
