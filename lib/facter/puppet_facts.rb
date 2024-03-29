# TODO: Maybe adopt what is used by stdlib puppet_vardir fact
#
require 'puppet'
require 'openssl'

# Puppet facts
module PuppetFacts
  def self.add_facts
    Facter.add(:puppet_environment) do
      setcode do
        # PuppetFacts.init_settings
        #       begin
        #         puts PuppetFacts.init_settings
        #       rescue Exception => e
        #         puts e
        #       end
        #         args = Puppet.settings.to_a.collect(&:first)
        #         values = Puppet.settings.values(Puppet[:environment].to_sym, :production)
        #         args.sort.each do |setting_name|
        #           value = values.interpolate(setting_name.to_sym)
        #           if value =~ 'etc'
        #             puts "#{setting_name} = #{value}"
        #           end
        #         end
        Puppet.settings.values(nil, :agent).interpolate(:environment).to_s
      end
    end

    Facter.add(:puppet_hostcert) do
      confine nfsroot_ro: [:false, 'false', false, nil]
      setcode do
        # PuppetFacts.init_settings
        Puppet[:hostcert].to_s
      end
    end

    Facter.add(:puppet_hostprivkey) do
      confine nfsroot_ro: [:false, 'false', false, nil]
      setcode do
        # PuppetFacts.init_settings
        Puppet[:hostprivkey].to_s
      end
    end

    Facter.add(:puppet_localcacert) do
      confine nfsroot_ro: [:false, 'false', false, nil]
      setcode do
        # PuppetFacts.init_settings
        Puppet[:localcacert].to_s
      end
    end
  end
  #     Facter.add(:puppet_ca_hash) do
  #       confine :nfsroot_ro => [:false, 'false', false]
  #       setcode do
  #         localcacert = Facter.value(:puppet_localcacert)
  #         content = Facter::Util::FileRead.read(localcacert)
  #         cert = OpenSSL::X509::Certificate.new(content)
  #         cert.issuer.hash.to_s(16)
  #       end
  #     end

  def self.init_settings
    return if Puppet.settings.global_defaults_initialized?
    case Puppet.version
    when %r{^(4|5)}
      Puppet.initialize_settings
    when %r{^5}
      Puppet.initialize_settings
    end
  end
end

PuppetFacts.add_facts
