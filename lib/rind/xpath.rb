# Current Xpath support is fairly basic but covers almost all axes and node tests.
# Predicates are limited to attribute and position checks. I intend to expand support
# but that should cover most of the needed functionality.
module Xpath
	# Xpath search of a node that returns a list of matching nodes.
	def s(path)
		node = self;

		# absolute paths to the top
		if '/' == path[0,1]
			while not node.parent.nil?
				node = node.parent
			end
			if 1 < path.length and '/' == path[1,1]
				path[0] = ''
			else
				path[0] = 'self::'
			end
		end

		# node check
		nodes = [node]
		path.split('/').each do |step|
			case step
			when ''
				step = 'descendant-or-self::node()'
			when '.'
				step = 'self::node()'
			when '..'
				step = 'parent::node()'
			end

			step.gsub!(/^@/, 'attribute::')

			step =~ /^(?:(.*?)::)?(.+?)(\[.*?)?$/
			axis, node_test, predicates = $1, $2, $3
			axis = 'child' if axis.nil?

			# find matching nodes
			nodes = nodes.collect{|node| node.find_matching_nodes(axis, node_test)}.flatten.compact

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

					nodes = nodes.find_all{|node| node.validate_predicate(predicate.clone, nodes.index(node)+1)}
					break if nodes.empty?
				end
			end

			return Rind::Nodes[] if nodes.empty?
		end

		Rind::Nodes[*nodes]
	end

	# Xpath search returning only the first matching node in the list.
	def sf(path)
		self.s(path).first
	end

	def find_matching_nodes(axis, node_test) # :nodoc:
		case axis
		when 'ancestor'
			self.ancestors.find_all{|node| node.is_matching_node?(node_test)}
		when 'ancestor-or-self'
			self.find_matching_nodes('self', node_test) + self.find_matching_nodes('ancestor', node_test)
		when 'attribute'
			'*' == node_test ? self[] : self[node_test] || []
		when 'child'
			self.is_leaf? ? [] : self.children.find_all{|node| node.is_matching_node?(node_test)}
		when 'descendant'
			self.descendants.find_all{|node| node.is_matching_node?(node_test)}
		when 'descendant-or-self'
			self.find_matching_nodes('self', node_test) + self.find_matching_nodes('descendant', node_test)
		when 'following-sibling'
			self.next_siblings.find_all{|node| node.is_matching_node?(node_test)}
		when 'parent'
			self.parent.is_matching_node?(node_test) ? [self.parent] : []
		when 'preceding-sibling'
			self.prev_siblings.find_all{|node| node.is_matching_node?(node_test)}
		when 'self'
			self.is_matching_node?(node_test) ? [self] : []
		else
			raise "Invalid axis: #{axis}"
		end
	end
	protected :find_matching_nodes

	def is_matching_node?(node_test) # :nodoc:
		case node_test
		when '*'
			self.is_a?(Rind::Text) ? false : true
		when 'comment()'
			self.is_a?(Rind::Comment) ? true : false
		when 'node()'
			true
		when 'processing-instruction()'
			self.is_a?(Rind::ProcessingInstruction) ? true : false
		when 'text()'
			self.is_a?(Rind::Text) ? true : false
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
	protected :is_matching_node?

	def validate_predicate(predicate, position) # :nodoc:
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
	protected :validate_predicate
end
