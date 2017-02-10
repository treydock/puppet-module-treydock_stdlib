module Puppet::Parser::Functions
  newfunction(:crypt_passwd, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Generates encrypted password similar to unix /etc/shadow

    For example:

        $password = "foo"
        $hash = crypt_passwd($password)
ENDHEREDOC

    require 'digest/sha2'

    if args.length < 1 or args.length > 2
      raise Puppet::ParseError, ("crypt_password(): wrong number of arguments (#{args.length}; must be at least 1)")
    end

    Puppet::Parser::Functions.function('fqdn_rand_string')

    password = args[0]
    salt = args[1]
    if salt.nil?
      salt = function_fqdn_rand_string([16])
    end

    hash = password.crypt("$6$" + salt)
    hash
  end
end