require 'puppet'
Facter.add('puppet_environment') do
  setcode do
    if ! Puppet.settings.global_defaults_initialized?
      Puppet.settings.initialize_global_settings
    end
    Puppet[:environment].to_s
  end
end
