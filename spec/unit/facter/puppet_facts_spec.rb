require 'spec_helper'
require 'facter/puppet_facts'

describe 'puppet_facts Facts' do
  before :each do
    PuppetFacts.add_facts
    Puppet[:logdir] = '/tmp'
    Puppet[:confdir] = '/tmp'
    Puppet[:vardir] = '/tmp'
  end
  after :each do
    Facter.clear
    Facter.clear_messages
  end

  it "puppet_environment should return production" do
    expect(Facter.fact(:puppet_environment).value).to eq('production')
  end

  it 'puppet_hostcert should be defined' do
    Puppet[:hostcert] = '/dne/fqdn.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(false)
    expect(Facter.value(:puppet_hostcert)).to eq('/dne/fqdn.pem')
  end

  it 'puppet_hostcert should be nil' do
    Puppet[:hostcert] = '/dne/fqdn.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(true)
    expect(Facter.value(:puppet_hostcert)).to be_nil
  end

  it 'puppet_hostprivkey should be defined' do
    Puppet[:hostprivkey] = '/dne/key.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(false)
    expect(Facter.value(:puppet_hostprivkey)).to eq('/dne/key.pem')
  end

  it 'puppet_hostprivkey should be nil' do
    Puppet[:hostprivkey] = '/dne/key.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(true)
    expect(Facter.value(:puppet_hostprivkey)).to be_nil
  end

  it 'puppet_localcacert should be defined' do
    Puppet[:localcacert] = '/dne/ca.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(false)
    expect(Facter.value(:puppet_localcacert)).to eq('/dne/ca.pem')
  end

  it 'puppet_localcacert should be nil' do
    Puppet[:localcacert] = '/dne/ca.pem'
    Facter.fact(:nfsroot_ro).stubs(:value).returns(true)
    expect(Facter.value(:puppet_localcacert)).to be_nil
  end

end
