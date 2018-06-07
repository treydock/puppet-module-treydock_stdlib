require 'spec_helper'

describe 'nodeset_collapse' do
  it 'should exist' do
    expect(Puppet::Parser::Functions.function('nodeset_collapse')).to eq('function_nodeset_collapse')
  end

  it 'should raise a ParseError no arguments passed' do
    is_expected.to run.with_params().and_raise_error(Puppet::ParseError)
  end

  it 'should raise a ParseError only 2 argument passed' do
    is_expected.to run.with_params('foo', 'bar').and_raise_error(Puppet::ParseError)
  end

  it 'should raise a ParseError if not passed array' do
    is_expected.to run.with_params('foo').and_raise_error(Puppet::ParseError)
  end

  it 'should return value for single element' do
    input = ['o0001']
    is_expected.to run.with_params(input).and_return('o0001')
  end

  it 'should return value for simple elements - consecutive' do
    input = ['o0001', 'o0002']
    is_expected.to run.with_params(input).and_return('o000[1-2]')
  end

  it 'should return value for simple elements - non-consecutive' do
    input = ['o0001', 'o0003']
    is_expected.to run.with_params(input).and_return('o000[1,3]')
  end

  it 'should return complex range - 1' do
    input = ['o0101', 'o0102', 'o0103', 'o0201']
    is_expected.to run.with_params(input).and_return('o0[101-103,201]')
  end

  it 'should return complex range - 2' do
    input = ['o0101', 'o0102', 'o0103', 'login01']
    is_expected.to run.with_params(input).and_return('o010[1-3],login01')
  end

  it 'should return complex range - 3' do
    input = ['o0101', 'o0102', 'o0103', 'login01', 'login02']
    is_expected.to run.with_params(input).and_return('o010[1-3],login0[1-2]')
  end

  it 'should return complex range - 4' do
    input = ['o0101', 'o0102', 'o0103', 'o0201', 'o0202', 'login01', 'login02']
    is_expected.to run.with_params(input).and_return('o0[101-103,201-202],login0[1-2]')
  end

  it 'should return range - racks' do
    input = ["rack3", "rack4", "rack5", "rack7", "rack8", "rack9", "rack10", "rack11", "rack12", "rack13", "rack14", "rack15", "rack18", "rack19"]
    is_expected.to run.with_params(input).and_return('rack[3-5,7-15,18-19]')
  end

  it 'should return datamovers' do
    input = ['datamover02', 'datamover01']
    is_expected.to run.with_params(input).and_return('datamover0[1-2]')
  end

  it 'should handle numeric and non-numeric' do
    input = ['sp5', 'sp5-test']
    is_expected.to run.with_params(input).and_return('sp5,sp5-test')
  end

  it 'should handle numeric and non-numeric - 2' do
    input = ['webdev01', 'webdev02', 'webdev02-ldap', 'webdev04']
    is_expected.to run.with_params(input).and_return('webdev0[1-2,4],webdev02-ldap')
  end

  it 'should handle common non-numeric suffix' do
    input = ['ruby01.ten', 'ruby02.ten']
    is_expected.to run.with_params(input).and_return('ruby0[1-2].ten')
  end

  it 'should handle common non-numeric suffix mixed with numeric suffix' do
    input = ['r0501', 'r0502', 'ruby01.ten', 'ruby02.ten']
    is_expected.to run.with_params(input).and_return('r050[1-2],ruby0[1-2].ten')
  end

  it 'should handle common non-numeric prefix with different suffix' do
    input = ['ldap0','ldap1-test']
    is_expected.to run.with_params(input).and_return('ldap0,ldap1-test')
  end
end
