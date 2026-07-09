class StringCalculator
  def add(numbers)
    return 0 if numbers.empty?

    delimiter = /,|\n/
    if numbers.start_with?('//')
      first_line, numbers = numbers.split("\n", 2)
      delimiter = first_line[2..]
    end

    parsed = numbers.split(delimiter).map(&:to_i)

    negatives = parsed.select { |n| n < 0 }
    raise "negatives not allowed #{negatives.join(',')}" unless negatives.empty?

    parsed.sum
  end
end

