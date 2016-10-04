require 'puppet'
Facter.add('puppet_environment') do
  setcode do
    if ! Puppet.settings.global_defaults_initialized?
      case Facter.value(:puppetversion)
      when /^3/
        Puppet.initialize_settings_for_run_mode(:agent)
      when /^4/
        Puppet.initialize_settings
      end
    end
    Puppet[:environment].to_s
  end
end
