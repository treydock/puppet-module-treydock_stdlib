module Puppet::Parser::Functions
  newfunction(:nodeset_collapse, :type => :rvalue, :doc => <<-EOS

    EOS
  ) do |args|
    debug = false
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

    # Awful hack to get common suffix of an array of strings
    # First remove common prefix and numeric characters from beginning of strings
    def self.common_suffix(m, c)
      return '' if m.empty?
      m_reduced = m.map { |n| n.gsub(c, '').gsub(/^[0-9]+/, '') }
      s1, s2 = m_reduced.min, m_reduced.max
      s1.reverse.each_char.with_index do |c, i|
        return s1[0...i].reverse if c != s2.reverse[i]
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

    puts "string_groups=#{string_groups}" if debug
    # For each string group, get common prefix and group those systems by their values without prefix
    common = {}
    common_all = []
    exceptions = []
    string_groups.each_pair do |str, str_nodes|
      if str_nodes.size == 1
        common[str_nodes[0]] = {'node' => str_nodes, 'suffix' => ''}
        next
      end
      c = self.common_prefix(str_nodes)
      s = self.common_suffix(str_nodes, c)
      puts "c=#{c}" if debug
      puts "s=#{s}" if debug

      # Handle case where common prefix is entire node name
      if str_nodes.include?(c)
        common_all << c
        str_nodes.delete(c)
      end
      if str_nodes.size == 1
        common[str_nodes[0]] = {'node' => str_nodes, 'suffix' => s}
        next
      end
      str_nodes.each_with_index do |node, i|
        common_uniq = node.gsub(c, '').gsub(s, '')
        puts "node=#{node} common_uniq=#{common_uniq}" if debug
        # Handle case where there is a non-numeric suffix that is not a common suffix
        if common_uniq !~ /^[0-9]+$/
          exceptions << node
          next
        end
        if ! common.has_key?(c)
          common[c] = {'node' => [], 'suffix' => s}
        end
        if common_uniq == ''
          common[c]['node'] = [node]
          next
        end
        common[c]['node'] << common_uniq
      end
    end
    puts "common=#{common}" if debug
    puts "exceptions=#{exceptions}" if debug
    puts "common_all=#{common_all}" if debug

    # For each common prefix group, get ranges and format return value
    common.each_pair do |c, d|
      n = d['node']
      if n.size == 1
        if n[0] != c
          node = c + n[0]
        else
          node = n[0]
        end
        puts "n.size=1 node=#{node}" if debug
        common_all << node unless common_all.include?(node)
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
      common_all << "#{c}[#{n_ranges.join(',')}]#{d['suffix']}"
    end

    (common_all + exceptions).join(',')
  end
end
