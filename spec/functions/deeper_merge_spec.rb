require 'spec_helper'

describe 'deeper_merge' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_return({}) }
  it { is_expected.to run.with_params('key' => 'value').and_return('key' => 'value') }
  it { is_expected.to run.with_params({}, '2').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params({}, 2).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params({}, '').and_return({}) }
  it { is_expected.to run.with_params({}, {}).and_return({}) }
  it { is_expected.to run.with_params({}, {}, {}).and_return({}) }
  it { is_expected.to run.with_params({}, {}, {}, {}).and_return({}) }
  it { is_expected.to run.with_params({ 'key' => 'value' }, '').and_return('key' => 'value') }
  it { is_expected.to run.with_params({ 'key1' => 'value1' }, 'key2' => 'value2').and_return('key1' => 'value1', 'key2' => 'value2') }

  describe 'when arguments have key collisions' do
    it 'prefers values from the last hash' do
      is_expected.to run \
        .with_params(
          { 'key1' => 'value1', 'key2' => 'value2' },
          'key2' => 'replacement_value', 'key3' => 'value3',
        ) \
        .and_return(
          'key1' => 'value1', 'key2' => 'replacement_value', 'key3' => 'value3',
        )
    end
    it {
      is_expected.to run \
        .with_params({ 'key1' => 'value1' }, { 'key1' => 'value2' }, 'key1' => 'value3') \
        .and_return('key1' => 'value3')
    }
  end

  describe 'when arguments have subhashes' do
    it {
      is_expected.to run \
        .with_params({ 'key1' => 'value1' }, 'key2' => 'value2', 'key3' => { 'subkey1' => 'value4' }) \
        .and_return('key1' => 'value1', 'key2' => 'value2', 'key3' => { 'subkey1' => 'value4' })
    }
    it {
      is_expected.to run \
        .with_params({ 'key1' => { 'subkey1' => 'value1' } }, 'key1' => { 'subkey2' => 'value2' }) \
        .and_return('key1' => { 'subkey1' => 'value1', 'subkey2' => 'value2' })
    }
    it {
      is_expected.to run \
        .with_params({ 'key1' => { 'subkey1' => { 'subsubkey1' => 'value1' } } }, 'key1' => { 'subkey1' => { 'subsubkey1' => 'value2' } }) \
        .and_return('key1' => { 'subkey1' => { 'subsubkey1' => 'value2' } })
    }
  end

  describe 'when arguments have sub arrays' do
    it 'does not remove duplicates' do
      is_expected.to run \
        .with_params(
          { 'key1' => ['value1'], 'key2' => 'value2' },
          'key1' => ['value1'], 'key2' => 'replacement_value', 'key3' => 'value3',
        ) \
        .and_return(
          'key1' => ['value1', 'value1'], 'key2' => 'replacement_value', 'key3' => 'value3',
        )
    end
    it {
      is_expected.to run \
        .with_params({ 'key1' => ['value1'] }, { 'key1' => ['value2'] }, 'key1' => ['value3']) \
        .and_return('key1' => ['value1', 'value2', 'value3'])
    }
  end

  it 'does not change the original hashes' do
    argument1 = { 'key1' => 'value1' }
    original1 = argument1.dup
    argument2 = { 'key2' => 'value2' }
    original2 = argument2.dup

    subject.call([argument1, argument2]) # rubocop:disable RSpec/NamedSubject
    expect(argument1).to eq(original1)
    expect(argument2).to eq(original2)
  end
end
