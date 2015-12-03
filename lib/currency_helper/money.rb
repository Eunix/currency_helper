class Money

  class UnknownConversionRate < StandardError;
  
  @@conversion_rates = {}

  attr_reader :amount, :currency

  # Creates new Money object
  #
  # Example:
  #   fifty_eur = Money.new(50, 'EUR')
  #   fifty_eur.amount   # => 50
  #   fifty_eur.currency # => "EUR"
  #   fifty_eur.inspect  # => "50.00 EUR"
  def initialize(amount, currency)
    @amount = BigDecimal.new(amount.to_s)
    @currency = currency
  end

  def inspect
    "#{'%.2f' % amount} #{currency}"
  end

  # Convert the Money object to a new Money object in different currency
  # using predefined conversions rates
  #
  # Example:
  #   Money.conversion_rates('EUR', {
  #     'USD'     => 1.11,
  #     'Bitcoin' => 0.0047
  #   })
  #
  #   fifty_eur = Money.new(50, 'EUR')
  #
  #   # Convert 50 EUR to USD
  #   fifty_eur.convert_to('USD') # => 55.50 USD
  def convert_to(different_currency)
    if @@conversion_rates[currency].nil? || @@conversion_rates[currency][different_currency].nil?
      raise UnknownConversionRate
    else
      self.class.new(@@conversion_rates[currency][different_currency] * amount, different_currency)
    end
  end

  # Returns the sum of two Money objects. If other money is in a different
  # currency, its amount value is automatically converted to this object
  # currency
  # 
  # Example:
  #   Money.new(50, 'EUR') + Money.new(20, 'USD') #=> 68.02 EUR
  def +(other_money)
    other_money = other_money.convert_to(currency)
    self.class.new(amount + other_money.amount, currency)
  end

  # Returns the difference of two Money objects. If other money is in 
  # a different currency, its amount value is automatically converted 
  # to this object currency
  # 
  # Example:
  #   Money.new(50, 'EUR') - Money.new(20, 'USD') #=> 31.98 EUR
  def -(other_money)
    other_money = other_money.convert_to(currency)
    self.class.new(amount - other_money.amount, currency)
  end

  # Returns the multiplication of two Money object or the Money object
  # with the given value.
  #
  # Raises ArgumentError if value is not Money object nor a number
  #
  # Example:
  #   Money.new(20, 'USD') * 3 #=> 60.00 USD
  def *(value)
    if value.is_a?(Numeric)
      self.class.new(amount * value, currency)
    elsif value.is_a?(self.class)
      value = value.convert_to(currency) if currency != value.currency
      self.class.new(amount * value.amount, currency)
    else
      raise ArgumentError
    end
  end

  # Returns the result of division of two Money object or the Money object
  # with the given value.
  #
  # Raises ArgumentError if value is not Money object nor a number
  #
  # Example:
  #   Money.new(50, 'EUR') / 2 #=> 25.00 EUR
  def /(value)
    if value.is_a?(Numeric) && !value.zero?
      self.class.new(amount / value, currency)
    elsif value.is_a?(self.class) && !value.amount.zero?
      value = value.convert_to(currency) if currency != value.currency
      self.class.new(amount / value.amount, currency)
    else
      raise ArgumentError
    end
  end

  # Compares two Money objects (greater than)
  #
  # Example:
  #   Money.new(50, 'EUR') > Money.new(20, 'EUR')
  def >(other_money)
    other_money = other_money.convert_to(currency) if currency != other_money.currency
    amount > other_money.amount
  end

  # Compares two Money objects (less than)
  #
  # Example:
  #   Money.new(10, 'USD') < Money.new(20, 'EUR')
  def <(other_money)
    other_money = other_money.convert_to(currency) if currency != other_money.currency
    amount < other_money.amount
  end

  # Checks two Money object
  #
  # Example:
  #   twenty_dollars = Money.new(20, 'USD')
  #   twenty_dollars == Money.new(20, 'USD') # => true
  #   twenty_dollars == Money.new(30, 'USD') # => false
  def ==(other_money)
    other_money = other_money.convert_to(currency) if currency != other_money.currency
    amount == other_money.amount
  end

  # Configures the currency rates with respect to a base currency
  #
  # Example:
  #   Money.conversion_rates('EUR', {
  #     'USD'     => 1.11,
  #     'Bitcoin' => 0.0047
  #   })
  def self.conversion_rates(base_currency, currency_rates)
    @@conversion_rates[base_currency] = currency_rates
    currency_rates.each do |k, v|
      next if v.zero?
      @@conversion_rates[k] = { base_currency => 1 / v }
    end
  end
end
