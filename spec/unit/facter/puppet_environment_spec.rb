require 'spec_helper'
#require 'facter/util/file_read'

describe 'puppet_environment Fact' do
  context 'production nodes' do
    before :each do
      Facter.clear
      Puppet.stubs(:[]).with(:environment).returns("production")
    end

    it "should return production" do
      expect(Facter.fact(:puppet_environment).value).to eq('production')
    end
  end

  context 'test nodes' do
    before :each do
      Facter.clear
      Puppet.stubs(:[]).with(:environment).returns("test")
    end

    it "should return production" do
      expect(Facter.fact(:puppet_environment).value).to eq('test')
    end
  end
end
