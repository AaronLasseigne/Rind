# Current Xpath support is fairly basic but covers almost all axes and node tests.
# Predicates are limited to attribute and position checks. I intend to expand support
# but that should cover most of the needed functionality.
module Xpath
	# Xpath search of a node that returns a list of matching nodes.
	def xpath_search(path)
		node = self;

		# absolute paths to the top
		if '/' == path[0,1]
			while not node.is_root?
				node = node.parent
			end
			if '/' == path[1,1]
				path[0,2] = 'descendant::' if path[2..8] == 'child::' or path[2...path.length] !~ /^[a-z-]+::/
			else
				path[0] = 'self::'
			end
		end

		# node check
		nodes = [node]
		path.scan(%r{(?:^\/?|\/)
							(?:([^\/]*?)::)? # axis
							([^\/\[]+)?      # node test
							((?:\[.+?\])*)   # predicates
		}x) do |axis, node_test, predicates|
			case node_test
			when nil
				axis = 'descendant-or-self'
				node_test = 'node()'
			when '.'
				axis = 'self'
				node_test = 'node()'
			when '..'
				axis = 'parent'
				node_test = 'node()'
			end

			axis = 'child' if axis.nil?

			node_test.gsub!(/^@/, 'attribute::')
			predicates.gsub!(/^@/, 'attribute::')

			# find matching nodes
			nodes.collect!{|node| node.xpath_find_matching_nodes(axis, node_test)}.flatten!
			nodes.compact!
			nodes.uniq!

			# check predicates
			if not predicates.nil?
				# true() and false()
				predicates.gsub!(/(true|false)\(\)/, '\1')
				# ==
				predicates.gsub!(/=/, '==')

				predicates.scan(/\[(.*?)\]/) do |predicate|
					predicate = predicate[0]
					# last()
					predicate.gsub!(/last\(\)/, nodes.length.to_s)

					nodes = nodes.find_all do |node|
						node.xpath_validate_predicate(predicate.clone, Rind::Nodes[*nodes].exact_index(node)+1)
					end
					break if nodes.empty?
				end
			end

			return Rind::Nodes[] if nodes.empty?
		end

		Rind::Nodes[*nodes]
	end
	alias :xs :xpath_search

	# Xpath search returning only the first matching node in the list.
	def xpath_search_first(path)
		self.xs(path).first
	end
	alias :xsf :xpath_search_first

	def xpath_find_matching_nodes(axis, node_test) # :nodoc:
		case axis
		when 'ancestor'
			self.ancestors.find_all{|node| node.xpath_is_matching_node?(node_test)}
		when 'ancestor-or-self'
			self.xpath_find_matching_nodes('self', node_test) + self.xpath_find_matching_nodes('ancestor', node_test)
		when 'attribute'
			'*' == node_test ? self[] : self[node_test] || []
		when 'child'
			self.is_leaf? ? [] : self.children.find_all{|node| node.xpath_is_matching_node?(node_test)}
		when 'descendant'
			self.descendants.find_all{|node| node.xpath_is_matching_node?(node_test)}
		when 'descendant-or-self'
			self.xpath_find_matching_nodes('self', node_test) + self.xpath_find_matching_nodes('descendant', node_test)
		when 'following-sibling'
			self.next_siblings.find_all{|node| node.xpath_is_matching_node?(node_test)}
		when 'parent'
			(not self.is_root? and self.parent.xpath_is_matching_node?(node_test)) ? [self.parent] : []
		when 'preceding-sibling'
			self.prev_siblings.find_all{|node| node.xpath_is_matching_node?(node_test)}
		when 'self'
			self.xpath_is_matching_node?(node_test) ? [self] : []
		else
			raise "Invalid axis: #{axis}"
		end
	end
	protected :xpath_find_matching_nodes

	def xpath_is_matching_node?(node_test) # :nodoc:
		case node_test
		when '*'
			not self.is_a?(Rind::Text)
		when 'comment()'
			self.is_a?(Rind::Comment)
		when 'node()'
			true
		when 'processing-instruction()'
			self.is_a?(Rind::ProcessingInstruction)
		when 'text()'
			self.is_a?(Rind::Text)
		else
			if self.is_a?(Rind::Element)
				if self.namespace_name == 'rind:html' and self.local_name == node_test
					true
				elsif self.expanded_name == node_test
					true
				end
		  else
				false
			end
		end
	end
	protected :xpath_is_matching_node?

	def xpath_validate_predicate(predicate, position) # :nodoc:
		# attribute replacement
		predicate.gsub!(/@([0-9a-zA-Z]+)/){self.respond_to?(:[]) ? "self[:#{$1}]" : 'nil'}
		# position()
		predicate.gsub!(/position\(\)/, position.to_s)

		valid = eval predicate
		# a number indicates a position request
		if valid.is_a? Fixnum
			valid == position
		else
			valid
		end
	end
	protected :xpath_validate_predicate
end
