Puppet::Functions.create_function(:nodeset_collapse) do
  dispatch :collapse do
    param 'Array', :nodes
  end

  def collapse(nodes)
    debug = false

    if nodes.size == 1
      return nodes[0]
    end

    # Extract common non-numeric values
    # This separates groups of nodes that can't be ranged together
    string_groups = {}
    nodes.each do |node|
      str = node[%r{([^0-9]+)}, 1]
      unless string_groups.key?(str)
        string_groups[str] = []
      end
      string_groups[str] << node
    end

    puts "string_groups=#{string_groups}" if debug
    # For each string group, get common prefix and group those systems by their values without prefix
    common = {}
    common_all = []
    exceptions = []
    string_groups.each_pair do |_str, str_nodes|
      if str_nodes.size == 1
        common[str_nodes[0]] = { 'node' => str_nodes, 'suffix' => '' }
        next
      end
      c = common_prefix(str_nodes)
      s = common_suffix(str_nodes, c)
      puts "c=#{c}" if debug
      puts "s=#{s}" if debug

      # Handle case where common prefix is entire node name
      if str_nodes.include?(c)
        common_all << c
        str_nodes.delete(c)
      end
      if str_nodes.size == 1
        common[str_nodes[0]] = { 'node' => str_nodes, 'suffix' => s }
        next
      end
      str_nodes.each_with_index do |node, _i|
        common_uniq = node.gsub(c, '').gsub(s, '')
        puts "node=#{node} common_uniq=#{common_uniq}" if debug
        # Handle case where there is a non-numeric suffix that is not a common suffix
        if common_uniq !~ %r{^[0-9]+$}
          exceptions << node
          next
        end
        unless common.key?(c)
          common[c] = { 'node' => [], 'suffix' => s }
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
        node = if n[0] != c
                 c + n[0]
               else
                 n[0]
               end
        puts "n.size=1 node=#{node}" if debug
        common_all << node unless common_all.include?(node)
        next
      end
      ranges = to_ranges(n)
      n_ranges = []
      ranges.each do |r|
        n_ranges << if r.begin == r.end
                      r.begin.to_s
                    else
                      "#{r.begin}-#{r.end}"
                    end
      end
      common_all << "#{c}[#{n_ranges.join(',')}]#{d['suffix']}"
    end

    (common_all + exceptions).join(',')
  end

  # https://gist.github.com/mamantoha/3898678
  def common_prefix(m)
    # Given a array of pathnames, returns the longest common leading component
    return '' if m.empty?
    s1 = m.min
    s2 = m.max
    s1.each_char.with_index do |c, i|
      return s1[0...i] if c != s2[i]
    end
    s1
  end

  # Awful hack to get common suffix of an array of strings
  # First remove common prefix and numeric characters from beginning of strings
  def common_suffix(m, c)
    return '' if m.empty?
    m_reduced = m.map { |n| n.gsub(c, '').gsub(%r{^[0-9]+}, '') }
    s1 = m_reduced.min
    s2 = m_reduced.max
    s1.reverse.each_char.with_index do |cc, i|
      return s1[0...i].reverse if cc != s2.reverse[i]
    end
    s1
  end

  # https://dzone.com/articles/convert-ruby-array-ranges
  def to_ranges(a)
    array = a.compact.uniq.sort_by(&:to_i)
    ranges = []
    unless array.empty?
      # Initialize the left and right endpoints of the range
      left = array.first
      right = nil
      array.each do |obj|
        # If the right endpoint is set and obj is not equal to right's successor
        # then we need to create a range.
        if right && obj != right.succ
          ranges << Range.new(left, right)
          left = obj
        end
        right = obj
      end
      ranges << Range.new(left, right)
    end
    ranges
  end
end
