# TODO: Maybe adopt what is used by stdlib puppet_vardir fact
#
require 'puppet'
require 'openssl'

module PuppetFacts
  def self.add_facts
    Facter.add(:puppet_environment) do
      setcode do
        PuppetFacts.init_settings
        Puppet[:environment].to_s
      end
    end

    Facter.add(:puppet_hostcert) do
      confine :nfsroot_ro => [:false, 'false', false]
      setcode do
        PuppetFacts.init_settings
        Puppet[:hostcert].to_s
      end
    end

    Facter.add(:puppet_hostprivkey) do
      confine :nfsroot_ro => [:false, 'false', false]
      setcode do
        PuppetFacts.init_settings
        Puppet[:hostprivkey].to_s
      end
    end

    Facter.add(:puppet_localcacert) do
      confine :nfsroot_ro => [:false, 'false', false]
      setcode do
        PuppetFacts.init_settings
        Puppet[:localcacert].to_s
      end
    end

=begin
    Facter.add(:puppet_ca_hash) do
      confine :nfsroot_ro => [:false, 'false', false]
      setcode do
        localcacert = Facter.value(:puppet_localcacert)
        content = Facter::Util::FileRead.read(localcacert)
        cert = OpenSSL::X509::Certificate.new(content)
        cert.issuer.hash.to_s(16)
      end
    end
=end

    def self.init_settings
      case Puppet.version
      when /^3/
        Puppet.initialize_settings_for_run_mode(:agent)
      when /^(4|5)/
        # Mimic parts of Puppet.do_initialize_settings_for_run_mode(:agent) which is private
        Puppet.settings.initialize_global_settings
        run_mode = Puppet::Util::RunMode[:agent]
        Puppet.settings.initialize_app_defaults(Puppet::Settings.app_defaults_for_run_mode(run_mode))
      end
    end

  end
end

PuppetFacts.add_facts
