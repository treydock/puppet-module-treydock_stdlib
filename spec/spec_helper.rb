RSpec.configure do |config|
  config.mock_with :rspec
end
require 'puppetlabs_spec_helper/module_spec_helper'

dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH.unshift(dir, File.join(dir, 'fixtures/modules/osc_facts/lib'))
$LOAD_PATH.unshift(dir, File.join(dir, 'fixtures/modules/nfsroot/lib'))

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue Exception => e
  warn "Coveralls disabled"
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    allow_any_instance_of(Facter::Util::Loader).to receive(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}
  end

  config.after :each do
    # Restore environment variables after execution of each test
    @old_env.each_pair {|k, v| ENV[k] = v}
    to_remove = ENV.keys.reject {|key| @old_env.include? key }
    to_remove.each {|key| ENV.delete key }
  end
end

def owens_fixtures
  File.read(fixtures('modules', 'osc_facts/files/owens_hosts.yaml'))
end

def ruby_fixtures
  File.read(fixtures('modules', 'osc_facts/files/ruby_hosts.yaml'))
end

Facter.add(:cluster) do
  setcode do
    'owens'
  end
end
