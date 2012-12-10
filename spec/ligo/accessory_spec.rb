require 'spec_helper'

describe Ligo::Accessory do
  before(:all) do
    @accessory = Ligo::Accessory.new
  end

  subject { @accessory }
  it { should respond_to :manufacturer}
  it { should respond_to :model}
  it { should respond_to :description}
  it { should respond_to :version}
  it { should respond_to :uri}
  it { should respond_to :serial}

  describe '#new' do

    context 'when called with nil' do
      it 'should raise ArgumentError' do
        expect { Ligo::Accessory.new(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when called with an empty Hash' do
      it 'should raise ArgumentError' do
        expect { Ligo::Accessory.new(Hash.new) }.to raise_error(ArgumentError)
      end
    end

    context 'when called with invalid data (> max length)' do
      before(:all) do
        @accessory_arg = {
          manufacturer: 'a',
          model:        'a',
          description:  'a',
          version:      'a',
          uri:          'a',
          serial:       (0...256).map{ ('a'..'z').to_a[rand(26)] }.join
        }
      end

      it 'should raise ArgumentError' do
        expect do
          Ligo::Accessory.new(@accessory_arg)
        end.to raise_error(ArgumentError,
                           'serial must contain at most 255 bytes')
      end
    end

    context 'when called with invalid data (wrong datatype)' do
      before(:all) do
        @accessory_arg = {
          manufacturer: 0,
          model:        'a',
          description:  'a',
          version:      'a',
          uri:          'a',
          serial:       'a'
        }
      end

      it 'should raise ArgumentError' do
        expect do
          Ligo::Accessory.new(@accessory_arg)
        end.to raise_error(ArgumentError,
                           'manufacturer is not a String')
      end
    end

    context 'when called with missing data' do
      before(:all) do
        @accessory_arg = {
          manufacturer: 'a',
          model:        'a',
          description:  'a',
          version:      'a',
          serial:       'a'
        }
      end

      it 'should raise ArgumentError' do
        expect do
          Ligo::Accessory.new(@accessory_arg)
        end.to raise_error(ArgumentError,
                           'Missing argument: uri')
      end
    end

  end # describe #new

  describe '#each' do
    it 'must be implemented soon'
  end # describe #each

  describe '#keys' do
    it 'must be implemented soon'
  end # describe #keys

end
