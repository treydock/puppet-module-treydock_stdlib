Puppet::Functions.create_function(:crypt_passwd) do
  dispatch :crypt do
    param 'String', :password
    optional_param 'String', :salt
  end

  def crypt(password, salt = nil)
    require 'digest/sha2'

    if salt.nil?
      salt = call_function('fqdn_rand_string', 16)
    end
    puts salt
    hash = password.crypt("$6$" + salt)
    hash
  end
end