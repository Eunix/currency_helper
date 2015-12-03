describe Money do
  describe '.new' do
    let(:amount) { 50 }
    let(:currency) { 'EUR' }
    subject { Money.new(amount, currency) }

    it 'should have amount to be BigDecimal' do
      expect(subject.amount.class).to eq(BigDecimal)
    end

    it 'should initialize with amount' do
      expect(subject.amount).to eq(amount)
    end

    it 'should initialize with currency' do
      expect(subject.amount).to eq(amount)
    end

    context 'with float amount' do
      let(:amount) { 12.23 }

      it 'has amount 12.23' do
        expect(subject.amount).to eq(12.23)
      end
    end
  end

  describe '.inspect' do
    let(:amount) { 50 }
    subject { Money.new(amount, 'USD') }

    it 'returns currency string with correct format' do
      expect(subject.inspect).to eq('50.00 USD')
    end

    context 'with float amount' do
      let(:amount) { 45.22 }

      it 'returns amount as it is' do
        expect(subject.inspect).to eq('45.22 USD')
      end
    end
  end

  describe '.convert_to' do
    subject { Money.new(50, 'EUR') }

    it 'raises error without conversion rates' do
      expect{subject.convert_to('USD')}.to raise_error(Money::UnknownConversionRate)  
    end

    context 'with convertion rates' do
      before do 
        Money.conversion_rates('EUR', {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })
      end

      it 'returns Money instance' do
        expect(subject.convert_to('USD').class).to eq(Money)
      end

      it 'converts to USD' do
        expect(subject.convert_to('USD').inspect).to eq('55.50 USD')
      end

      it 'converts to BitCoin' do
        expect(subject.convert_to('Bitcoin').inspect).to eq('0.23 Bitcoin')
      end

      it 'raises error with unknown currency' do
        expect{subject.convert_to('RUR')}.to raise_error(Money::UnknownConversionRate) 
      end

      it 'can perform reverse convertation with base currency' do
        money = Money.new(100, 'USD')
        expect(money.convert_to('EUR').inspect).to eq('90.09 EUR')
      end
    end
  end

  context 'using arithmethic operations' do
    before do 
      Money.conversion_rates('EUR', {
        'USD'     => 1.11,
        'Bitcoin' => 0.0047
      })
    end
    
    let(:money1) { Money.new(50, 'EUR') }
    let(:money2) { Money.new(20, 'USD') }

    describe '.+' do
      subject { money1 + money2 }

      it 'can sum two Money object' do
        expect(subject.inspect).to eq('68.02 EUR')
      end

      it 'has Money object in result of sum' do
        expect(subject.class).to eq(Money)
      end
    end

    describe '.-' do
      subject { money1 - money2 }

      it 'can subtract two Money object' do
        expect(subject.inspect).to eq('31.98 EUR')
      end

      it 'has Money object in result of subtract' do
        expect(subject.class).to eq(Money)
      end
    end

    describe '.*' do
      it 'raises error with bad argument' do
        expect { money1 * '12' }.to raise_error(ArgumentError)
      end

      it 'returns multiplication with number' do
        expect((money2 * 3).inspect).to eq('60.00 USD')
      end

      it 'returns multiplication with other Money object' do
        expect((money1 * money2).inspect).to eq('900.90 EUR')
      end

      it 'returns multiplication with the same currency Money object' do
        expect((money1 * Money.new(10, 'EUR')).inspect).to eq('500.00 EUR')
      end
    end

    describe './' do
      it 'raises error with bad argument' do
        expect { money1 / '12' }.to raise_error(ArgumentError)
      end

      it 'raises error with zero' do
        expect { money1 / 0 }.to raise_error(ArgumentError)
        expect { money1 / Money.new(0, 'EUR') }.to raise_error(ArgumentError)
      end

      it 'divides with number' do
        expect((money1 / 2).inspect).to eq('25.00 EUR')
      end

      it 'divides with other Money object' do
        expect((money1 / money2).inspect).to eq('2.78 EUR')
      end

      it 'divides with the same currency Money object' do
        expect((money1 / Money.new(10, 'EUR')).inspect).to eq('5.00 EUR')
      end
    end
  end

  context 'compating two Money object' do
    before do 
      Money.conversion_rates('EUR', {
        'USD'     => 1.11,
        'Bitcoin' => 0.0047
      })
    end
    
    let(:money1) { Money.new(50, 'EUR') }
    let(:money2) { Money.new(20, 'USD') }

    describe '>.' do
      it 'returns comparison of two Money objects' do
        expect(money2 > Money.new(5, 'USD')).to be true
      end
    end

    describe '<.' do
      it 'returns comparison of two Money objects' do
        expect(money1 < money2).to be false
      end
    end

    describe '.==' do
      it 'checks two Money object in same currency' do
        expect(money1 == Money.new(50, 'EUR')).to be true
      end

      it 'checks two Money object in different currency' do
        expect(money1 == money2).to be false
      end
    end
  end
end
