require_relative 'string-calculator'

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

  it 'supports a custom delimiter declared on the first line' do
    expect(StringCalculator.new.add("//;\n1;2")).to eq(3)
  end

  it 'raises an exception naming the negative number when a negative is passed' do
    expect { StringCalculator.new.add('1,-2,3') }.to raise_error('negatives not allowed -2')
  end

  it 'ignores numbers greater than 1000 in the resulting sum' do
    expect(StringCalculator.new.add('1,1001,2')).to eq(3)
  end

  it 'supports a custom delimiter of any length wrapped in square brackets' do
    expect(StringCalculator.new.add("//[***]\n1***2***3")).to eq(6)
  end

  it 'supports multiple custom delimiters declared on the first line' do
    expect(StringCalculator.new.add("//[*][%]\n1*2%3")).to eq(6)
  end
end
