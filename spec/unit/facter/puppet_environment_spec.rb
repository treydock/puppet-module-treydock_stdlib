require 'spec_helper'
#require 'facter/util/file_read'

describe 'puppet_environment Fact' do
  context 'production nodes' do
    before :each do
      Facter.clear
    end

    it "should return production" do
      expect(Facter.fact(:puppet_environment).value).to eq('production')
    end
  end
end
