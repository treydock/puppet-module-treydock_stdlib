require 'spec_helper'
require 'facter/puppet_facts'

describe 'puppet_facts Facts' do
  before :each do
    Puppet[:logdir] = '/tmp'
    Puppet[:confdir] = '/tmp'
    Puppet[:vardir] = '/tmp'
    PuppetFacts.add_facts
  end
  after :each do
    Facter.clear
    Facter.clear_messages
  end

  it 'puppet_environment should return production' do
    expect(Facter.fact(:puppet_environment).value).to eq('production')
  end

  it 'puppet_hostcert should be defined' do
    Puppet[:hostcert] = '/dne/fqdn.pem'
    expect(Facter.value(:puppet_hostcert)).to eq('/dne/fqdn.pem')
  end

  it 'puppet_hostprivkey should be defined' do
    Puppet[:hostprivkey] = '/dne/key.pem'
    expect(Facter.value(:puppet_hostprivkey)).to eq('/dne/key.pem')
  end

  it 'puppet_localcacert should be defined' do
    Puppet[:localcacert] = '/dne/ca.pem'
    expect(Facter.value(:puppet_localcacert)).to eq('/dne/ca.pem')
  end

  context 'nfsroot_ro => false' do
    before(:each) do
      allow(Facter.fact(:nfsroot_ro)).to receive(:value).and_return(false)
    end

    it 'puppet_hostcert should be defined' do
      Puppet[:hostcert] = '/dne/fqdn.pem'
      expect(Facter.value(:puppet_hostcert)).to eq('/dne/fqdn.pem')
    end

    it 'puppet_hostprivkey should be defined' do
      Puppet[:hostprivkey] = '/dne/key.pem'
      expect(Facter.value(:puppet_hostprivkey)).to eq('/dne/key.pem')
    end

    it 'puppet_localcacert should be defined' do
      Puppet[:localcacert] = '/dne/ca.pem'
      expect(Facter.value(:puppet_localcacert)).to eq('/dne/ca.pem')
    end
  end

  context 'nfsroot_ro => true' do
    before(:each) do
      allow(Facter.fact(:nfsroot_ro)).to receive(:value).and_return(true)
    end

    it 'puppet_hostcert should be nil' do
      Puppet[:hostcert] = '/dne/fqdn.pem'
      expect(Facter.value(:puppet_hostcert)).to be_nil
    end

    it 'puppet_hostprivkey should be nil' do
      Puppet[:hostprivkey] = '/dne/key.pem'
      expect(Facter.value(:puppet_hostprivkey)).to be_nil
    end

    it 'puppet_localcacert should be nil' do
      Puppet[:localcacert] = '/dne/ca.pem'
      expect(Facter.value(:puppet_localcacert)).to be_nil
    end
  end
end
