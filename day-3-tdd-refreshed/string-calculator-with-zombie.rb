# Z : Zero
# O : One
# M : Many
# B : Boundaries
# I : Interfaces
# E : Exceptions


class StringCalculator
  def add(numbers)
    return 0 if numbers.empty?
    numbers.split(',').map(&:to_i).sum
  end
end

