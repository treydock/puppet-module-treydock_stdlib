dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dir, File.join(dir, 'fixtures/modules/nfsroot/lib'))

RSpec.configure do |config|
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key { |k| @old_env[k] = ENV[k] }
  end

  config.after :each do
    # Restore environment variables after execution of each test
    @old_env.each_pair { |k, v| ENV[k] = v }
    to_remove = ENV.keys.reject { |key| @old_env.include? key }
    to_remove.each { |key| ENV.delete key }
  end
end
