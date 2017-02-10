require 'spec_helper'

describe 'crypt_passwd' do
  it 'should exist' do
    expect(Puppet::Parser::Functions.function('crypt_passwd')).to eq('function_crypt_passwd')
  end

  it 'should raise a ParseError no arguments passed' do
    is_expected.to run.with_params().and_raise_error(Puppet::ParseError)
  end

  it 'should return hashed passwd' do
    case RbConfig::CONFIG['host_os']
    when /darwin/
      expected = '$6A86JNndVTdM'
    when /linux/
      expected = '$6$a24731p2qrvidko4$lxiCXG0Y4vONMY5SbLZiPM7MTmrtPxD63bPt9bUFtZ2YlQkr2t6hvvsAVlUtr7FrmWeupa69P/5UOfirrgUbn0'
    end
    is_expected.to run.with_params('foo', 'a24731p2qrvidko4').and_return(expected)
  end
end
