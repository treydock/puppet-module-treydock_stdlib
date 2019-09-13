require 'spec_helper'

describe 'crypt_passwd' do
  it { is_expected.not_to eq(nil) }

  it 'raises a ParseError no arguments passed' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it 'returns hashed passwd' do
    case RbConfig::CONFIG['host_os']
    when %r{darwin}
      expected = '$6A86JNndVTdM'
    when %r{linux}
      expected = '$6$a24731p2qrvidko4$lxiCXG0Y4vONMY5SbLZiPM7MTmrtPxD63bPt9bUFtZ2YlQkr2t6hvvsAVlUtr7FrmWeupa69P/5UOfirrgUbn0'
    end
    is_expected.to run.with_params('foo', 'a24731p2qrvidko4').and_return(expected)
  end

  it 'returns hashed passwd when no salt provided' do
    case RbConfig::CONFIG['host_os']
    when %r{darwin}
      expected = '$6A86JNndVTdM'
    when %r{linux}
      expected = '$6$1TxI7LtBrqFAsbIL$2IBXdkJ827KhHUmkZ5T/l/J0t589jxu76BTpVUeS9qN.0ktTwrfS/6Dw8tOUBh4KKmcZYOJkYVLBrUomDFzlo/'
    end
    is_expected.to run.with_params('foo').and_return(expected)
  end
end
