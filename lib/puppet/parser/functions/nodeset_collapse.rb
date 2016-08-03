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
      array = a.compact.uniq.sort
      ranges = []
      if !array.empty?
        # Initialize the left and right endpoints of the range
        left, right = a.first, nil
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
    string_groups.each_pair do |str, str_nodes|
      if str_nodes.size == 1
        common[str_nodes[0]] = str_nodes
        next
      end
      c = self.common_prefix(str_nodes)
      str_nodes.each_with_index do |node, i|
        if i == (str_nodes.size - 1)
          break
        end
        if ! common.has_key?(c)
          common[c] = []
        end
        common[c] << node.gsub(c, '')
        if i == (str_nodes.size - 2)
          common[c] << str_nodes[i+1].gsub(c, '')
        end
      end
    end

    # For each common prefix group, get ranges and format return value
    common_all = []
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

    common_all.join(',')
  end
end
