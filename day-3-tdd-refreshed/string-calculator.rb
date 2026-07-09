class StringCalculator
  def add(numbers)
    return 0 if numbers.empty?

    delimiter = /,|\n/
    if numbers.start_with?('//')
      first_line, numbers = numbers.split("\n", 2)
      delimiter = first_line[2..]
    end

    numbers.split(delimiter).map(&:to_i).sum
  end
end

