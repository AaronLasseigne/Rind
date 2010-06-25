module Css
	# CSS selector search of a node that returns a list of matching nodes.
	def css_search(path)
		node_name_scan = /(?:[\w|]|\*)/
		predicate_scan = %r{(
			[.#][\w\-]+|         # '.' and '#' shortcuts for id and class selectors
			\[.+?\]|             # attribute selectors
			:[\w\-]+(?:\(.*?\))? # structural pseudo-classes
		)}x

		# node check
		nodes = [self]
		path.scan(%r{
			(\Aself::|\s*[ >+~]\s*)? # axis
			((?:#{node_name_scan}+\|)?#{node_name_scan}+)? # (namespace_name|)local_name
			#{predicate_scan}*
		}xo) do |axis, node_test, predicates|
			# having no forced match causes scan to throw one more on at the end
			next if axis.nil? and node_test.nil? and predicates.nil?

			# clean up and default
			if not axis.nil?
				axis.strip!
				axis = ' ' if axis.empty?
			end
			node_test = '*' if node_test.nil?

			# find matching nodes
			nodes.collect!{|node| node.css_find_matching_nodes(axis, node_test)}.flatten!
			nodes.compact!

			# check predicates
			if not predicates.nil?
				predicates.scan(/#{predicate_scan}/o) do |predicate|
					predicate = predicate[0]

					nodes = nodes.find_all{|node| node.css_validate_predicate(predicate.clone)}
					break if nodes.empty?
				end
			end

			return Rind::Nodes[] if nodes.empty?
		end

		Rind::Nodes[*nodes]
	end
	alias :cs :css_search

	# CSS selector search returning only the first matching node in the list.
	def css_search_first(path)
		self.cs(path).first
	end
	alias :csf :css_search_first

	def css_find_matching_nodes(axis, node_test) # :nodoc:
		case axis
		when nil
			self.css_find_matching_nodes('self::', node_test) + self.css_find_matching_nodes(' ', node_test)
		when 'self::'
			self.css_is_matching_node?(node_test) ? [self] : []
		when ' '
			self.descendants.find_all{|node| node.css_is_matching_node?(node_test)}
		when '>'
			self.is_leaf? ? [] : self.children.find_all{|node| node.css_is_matching_node?(node_test)}
		when '+'
			next_node = self.next
			(not next_node.nil? and next_node.css_is_matching_node?(node_test)) ? [next_node] : []
		when '~'
			self.next_siblings.find_all{|node| node.css_is_matching_node?(node_test)}
		else
			raise "Invalid axis: #{axis}"
		end
	end
	protected :css_find_matching_nodes

	def css_is_matching_node?(node_test) # :nodoc:
		node_test =~ /^(?:(.*)\|)?(.+)$/
		namespace_name, local_name = $1, $2
		namespace_name.sub!(/\|/, ':') if not namespace_name.nil?

		# namespace name checks
		if not namespace_name.nil?
			# namespace is only valid for Elements
			return false if not self.is_a?(Rind::Element)

			# make sure the namespace requested matches the element's namespace
			return false if not namespace_name.empty? and namespace_name != '*' and namespace_name != self.namespace_name

			# if it's specifically empty (|E) then it needs to match the default
			return false if namespace_name.empty? and self.namespace_name != 'rind:html'
		end

		# local name checks
		case local_name
		when '*'
			not self.is_a?(Rind::Text)
		else
			(self.is_a?(Rind::Element) and local_name == self.local_name)
		end
	end
	protected :css_is_matching_node?

	def css_validate_predicate(predicate) # :nodoc:
		return self[:id] == predicate[1...predicate.length] if predicate[0,1] == '#'
		return self[:class] =~ /\b#{predicate[1...predicate.length]}\b/ if predicate[0,1] == '.'

		case predicate
		when ':root'
			self.is_root?
		when %r{^
			:nth-(last-)?(child|of-type)\(\s*(
				-?\d*?n(?:\s*[+-]\s*\d+)?| # Xn + Y
				-?\d+|
				odd|even
			)\s*\)$}x
			if not self.is_root?
				from_last, check, value = (not $1.nil?), $2, $3

				children = self.parent.children
				children = children.cf(self.expanded_name) if check == 'of-type'

				# n
				if value =~ /^-?\d+$/
					value = value.to_i
					value = from_last ? children.length - value : value - 1
					return false if value < 0
					return children[value].equal?(self)
				end

				# odd or even
				value = '2n+1' if value == 'odd'
				value = '2n' if value == 'even'

				# an + b
				value =~ /(-?\d*)?n\s*([+-]\s*\d+)?/
				a = 1.0
				if $1 == '-'
					a = -1.0
				elsif not $1.nil?
					a = $1.to_f
				end
				b = $2.nil? ? 0 : $2.sub(/[+ ]/, '').to_i

				if a == 0
					value = from_last ? children.length - b : b - 1
					return false if value < 0
					return children[value].equal?(self)
				else
					# flip an + b = css_index and look for the correct n value
					n = ((
						from_last ?
						children.length - children.exact_index(self) :
						children.exact_index(self) + 1
					) - b) / a
					return (n >= 0 and n == n.to_i)
				end
			end
		when ':first-child'
			self.css_validate_predicate(':nth-child(1)')
		when ':last-child'
			self.css_validate_predicate(":nth-last-child(1)")
		when ':first-of-type'
			self.css_validate_predicate(':nth-of-type(1)')
		when ':last-of-type'
			self.css_validate_predicate(":nth-last-of-type(1)")
		when ':only-child'
			self.parent.children.length == 1 if not self.is_root?
		when ':only-of-type'
			if not self.is_root?
				self.parent.children.each do |child|
					return false if child.expanded_name == self.expanded_name and not child.equal?(self)
				end
				true
			end
		when ':empty'
			self.is_leaf?
		when ':checked'
			true if self[:checked] or self[:CHECKED] or self[:selected] or self[:SELECTED]
		when /^:not\((.*)\)$/
			next_predicate = $1
			next_predicate << ')' if next_predicate =~ /^:.*\([^)]*$/ # for some reason the last ")" isn't being captured
			Rind::Nodes[self].cf(next_predicate).empty?
		# [a="b"]
		when %r{^\[
			(.*?)          # attribute
			(?:
				([~^$*|]?=)  # operator
				(["'])(.*)\3 # "value" or 'value'
			)?\]$}x
			attribute, operation, value = $1, $2, $4
			case operation
			when '='
				self[attribute] == value
			when '~='
				self[attribute] =~ /\b#{value}\b/
			when '^='
				self[attribute] =~ /^#{value}/
			when '$='
				self[attribute] =~ /#{value}$/
			when '*='
				self[attribute] =~ /#{value}/
			when '|='
				self[attribute] =~ /^#{value}(-|$)/
			else
				not self[attribute].nil?
			end
		else
			raise "Invalid predicate: #{predicate}"
		end
	end
	protected :css_validate_predicate
end
