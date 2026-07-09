# Z : Zero
# O : One
# M : Many
# B : Boundaries
# I : Interfaces
# E : Exceptions


class StringCalculator
  def add(numbers)
    raise TypeError, 'input must be a string' unless numbers.is_a?(String)
    return 0 if numbers.empty?

    delimiter = /,|\n/
    if numbers.start_with?('//')
      first_line, numbers = numbers.split("\n", 2)
      delimiter = first_line[2..]
      if delimiter.start_with?('[')
        delimiter = Regexp.union(delimiter.scan(/\[(.*?)\]/).flatten)
      end
    end

    numbers.split(delimiter).map(&:to_i).sum
  end
end