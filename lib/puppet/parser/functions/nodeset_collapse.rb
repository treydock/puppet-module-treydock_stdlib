module Puppet::Parser::Functions
  newfunction(:nodeset_collapse, :type => :rvalue, :doc => <<-EOS

    EOS
  ) do |args|

    # Validate the number of args
    if args.size != 1
      raise(Puppet::ParseError, "nodeset_collapse(): Takes exactly one " +
            "argument, but #{args.size} given.")
    end

    nodes = args[0]

    if ! nodes.is_a?(Array)
      raise(Puppet::ParseError, "nodeset_collapse(): unexpected argument type #{nodes.class}, " +
            "must be an array")
    end

    if nodes.size == 1
      return nodes[0]
    end

    # https://gist.github.com/mamantoha/3898678
    def self.common_prefix(m)
      # Given a array of pathnames, returns the longest common leading component
      return '' if m.empty?
      s1, s2 = m.min, m.max
      s1.each_char.with_index do |c, i|
        return s1[0...i] if c != s2[i]
      end
      return s1
    end

    # https://dzone.com/articles/convert-ruby-array-ranges
    def self.to_ranges(a)
      array = a.compact.uniq.sort_by(&:to_i)
      ranges = []
      if !array.empty?
        # Initialize the left and right endpoints of the range
        left, right = array.first, nil
        array.each do |obj|
          # If the right endpoint is set and obj is not equal to right's successor 
          # then we need to create a range.
          if right && obj != right.succ
            ranges << Range.new(left,right)
            left = obj
          end
          right = obj
        end
        ranges << Range.new(left,right)
      end
      ranges
    end

    # Extract common non-numeric values
    # This separates groups of nodes that can't be ranged together
    string_groups = {}
    nodes.each do |node|
      str = node[/([^0-9]+)/, 1]
      if ! string_groups.has_key?(str)
        string_groups[str] = []
      end
      string_groups[str] << node
    end

    # For each string group, get common prefix and group those systems by their values without prefix
    common = {}
    common_all = []
    exceptions = []
    string_groups.each_pair do |str, str_nodes|
      if str_nodes.size == 1
        common[str_nodes[0]] = str_nodes
        next
      end
      c = self.common_prefix(str_nodes)
      # Handle case where common prefix and numeric are followed by non-numeric.
      # These are exceptions
      str_nodes.dup.each do |n|
        numeric_n = n.gsub(c, '')
        if numeric_n.to_i.to_s != numeric_n
          exceptions << n
          str_nodes.delete(n)
        end
      end
      # Handle case where common prefix is entire node name
      if str_nodes.include?(c)
        common_all << c
        str_nodes.delete(c)
      end
      if str_nodes.size == 1
        common[str_nodes[0]] = str_nodes
        next
      end
      str_nodes.each_with_index do |node, i|
        if i == (str_nodes.size - 1)
          break
        end
        if ! common.has_key?(c)
          common[c] = []
        end
        common_uniq = node.gsub(c, '')
        if common_uniq == ''
          common[c] = [node]
          next
        end
        common[c] << common_uniq
        if i == (str_nodes.size - 2)
          common[c] << str_nodes[i+1].gsub(c, '')
        end
      end
    end

    # For each common prefix group, get ranges and format return value
    common.each_pair do |c, n|
      if n.size == 1
        common_all << n[0]
        next
      end
      ranges = self.to_ranges(n)
      n_ranges = []
      ranges.each do |r|
        if r.begin == r.end
          n_ranges << r.begin.to_s
        else
          n_ranges << "#{r.begin}-#{r.end}"
        end
      end
      common_all << "#{c}[#{n_ranges.join(',')}]"
    end

    (common_all + exceptions).join(',')
  end
end
