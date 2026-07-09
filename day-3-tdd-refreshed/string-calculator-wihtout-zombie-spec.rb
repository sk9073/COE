require_relative 'string-calculator'

describe StringCalculator do
  it 'returns 0 for an empty string' do
    expect(StringCalculator.new.add('')).to eq(0)
  end

  it 'returns sum of given input numbers' do
    expect(StringCalculator.new.add('1')).to eq(1)    
  end 
end
