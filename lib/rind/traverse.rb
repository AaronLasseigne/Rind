module Traverse
	# Creates a Rind::Nodes list of all ancestors. If an Xpath
	# is provided it will only return the nodes that match.
	def ancestors(path = nil)
		node = self
		ancestors = Rind::Nodes[]
		while not node.parent.nil?
			node = node.parent
			ancestors.push(node)
		end

		(path.nil? or ancestors.empty?) ? ancestors : ancestors.xf(path)
	end

	# Creates a Rind::Nodes list of all descendants. If an Xpath
	# is provided it will only return the nodes that match.
	def descendants(path = nil)
		descendants = Rind::Nodes[]
		if not self.is_leaf?
			descendants.push(*self.children)

			self.children.each do |child|
				child_descendants = child.descendants
				descendants.push(*child_descendants) if not child_descendants.nil?
			end
		end
		(path.nil? or descendants.empty?) ? descendants : descendants.xf(path)
	end

	# Returns the first descendant node. If an Xpath is provided
	# it will return the first one that matches.
	def down(path = nil)
		if not self.is_leaf?
			# if there's not path then send back the first child
			if path.nil?
				self.children.first
			else
				nodes = self.children.xf(path)
				if nodes.empty?
					self.children.each do |child|
						node = child.down(path)
						return node if not node.nil?
					end
					nil
				else
					nodes.first
				end
			end
		end
	end

	# Returns the first sibling that follows the current node in
	# the list of siblings. If an Xpath is provided it will return
	# the first one that matches.
	def next(path = nil)
		children = self.parent.children
		self_index = children.exact_index(self)
		if path.nil?
			children[self_index + 1]
		else
			(self_index + 1).upto(children.length) do |i|
				return children[i] if not Rind::Nodes[children[i]].xf(path).empty?
			end
		end
	end

	# Creates a Rind::Nodes list of all siblings that follow the
	# current node in the list of siblings. If an Xpath is provided
	# it will only return the nodes that match.
	def next_siblings(path = nil)
		children = self.parent.children
		siblings = Rind::Nodes[*children[children.exact_index(self)+1..children.length-1]]
		path.nil? ? siblings : siblings.xf(path)
	end

	# Returns the first sibling that proceeds the current node in
	# the list of siblings. If an Xpath is provided it will return
	# the first one that matches.
	def prev(path = nil)
		children = self.parent.children
		self_index = children.exact_index(self)
		if self_index == 0
			nil
		elsif path.nil?
			children[self_index - 1]
		else
			0.upto(self_index - 1) do |i|
				return children[i] if not Rind::Nodes[children[i]].xf(path).empty?
			end
		end
	end

	# Creates a Rind::Nodes list of all siblings that proceed the
	# current node in the list of siblings. If an Xpath is provided
	# it will only return the nodes that match.
	def prev_siblings(path = nil)
		children = self.parent.children
		siblings = Rind::Nodes[*children[0...children.exact_index(self)]]
		path.nil? ? siblings : siblings.xf(path)
	end

	# Creates a Rind::Nodes list of all siblings. If an Xpath is
	# provided it will only return the nodes that match.
	def siblings(path = nil)
		siblings = Rind::Nodes[*self.parent.children.find_all{|child| not child.equal? self}]
		path.nil? ? siblings : siblings.xf(path)
	end

	# Returns the first ancestor node. If an Xpath is provided
	# it will return the first one that matches.
	def up(path = nil)
		if path.nil?
			self.parent
		else
			node = self
			while not node.parent.nil?
				node = node.parent
				return node if not Rind::Nodes[node].xf(path).empty?
			end
			nil
		end
	end
end
