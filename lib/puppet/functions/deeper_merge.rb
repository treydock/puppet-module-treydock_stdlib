Puppet::Functions.create_function(:deeper_merge) do
  dispatch :merge do
    repeated_param 'Variant[Hash, Undef, String[0,0]]', :args
    return_type 'Hash'
  end

  def merge(*args)
    deeper_merge = proc do |hash1, hash2|
      hash1.merge(hash2) do |_key, old_value, new_value|
        if old_value.is_a?(Hash) && new_value.is_a?(Hash)
          deeper_merge.call(old_value, new_value)
        elsif old_value.is_a?(Array) && new_value.is_a?(Array)
          old_value + new_value
        else
          new_value
        end
      end
    end

    result = {}
    args.each do |arg|
      next if arg.is_a?(String) && arg.empty? # empty string is synonym for puppet's undef
      next if arg.nil?

      result = deeper_merge.call(result, arg)
    end
    result
  end
end
