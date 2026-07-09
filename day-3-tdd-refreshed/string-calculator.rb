class StringCalculator
  def add(numbers)
    return 0 if numbers.empty?

    delimiter = /,|\n/
    if numbers.start_with?('//')
      first_line, numbers = numbers.split("\n", 2)
      delimiter = first_line[2..]
      if delimiter.start_with?('[')
        delimiter = Regexp.union(delimiter.scan(/\[(.*?)\]/).flatten)
      end
    end

    parsed = numbers.split(delimiter).map(&:to_i)

    negatives = parsed.select { |n| n < 0 }
    raise "negatives not allowed #{negatives.join(',')}" unless negatives.empty?

    numbers_less_than_1000 = parsed.select {|n| n < 1000}
    numbers_less_than_1000.sum
  end
end

