module Traverse
	# Creates a Rind::Nodes list of all ancestors. If an Xpath
	# is provided it will only return the nodes that match.
	def ancestors(path = nil)
		node = self
		ancestors = Rind::Nodes.new()
		while not node.parent.nil?
			node = node.parent
			ancestors.push(node)
		end

		(path.nil? or ancestors.empty?) ? ancestors : ancestors.filter(path)
	end

	# Creates a Rind::Nodes list of all descendants. If an Xpath
	# is provided it will only return the nodes that match.
	def descendants(path = nil)
		descendants = Rind::Nodes.new()
		if self.respond_to? :children and not self.children.empty?
			descendants.push(*self.children)

			self.children.each do |child|
				child_descendants = child.descendants
				descendants.push(*child_descendants) if not child_descendants.nil?
			end
		end
		(path.nil? or descendants.empty?) ? descendants : descendants.filter(path)
	end

	# Returns the first descendant node. If an Xpath is provided
	# it will return the first one that matches.
	def down(path = nil)
		if self.respond_to? :children and not self.children.empty?
			# if there's not path then send back the first child
			if path.nil?
				self.children.first
			else
				nodes = self.children.filter(path)
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
		self_index = children.index(self)
		if path.nil?
			children[self_index + 1]
		else
			(self_index + 1).upto(children.length) do |i|
				return children[i] if not Rind::Nodes.new([children[i]]).filter(path).empty?
			end
		end
	end

	# Creates a Rind::Nodes list of all siblings that follow the
	# current node in the list of siblings. If an Xpath is provided
	# it will only return the nodes that match.
	def next_siblings(path = nil)
		children = self.parent.children
		siblings = Rind::Nodes.new(children[children.index(self)+1..children.length-1])
		path.nil? ? siblings : siblings.filter(path)
	end

	# Returns the first sibling that proceeds the current node in
	# the list of siblings. If an Xpath is provided it will return
	# the first one that matches.
	def prev(path = nil)
		children = self.parent.children
		self_index = children.index(self)
		if self_index == 0
			nil
		elsif path.nil?
			children[self_index - 1]
		else
			0.upto(self_index - 1) do |i|
				return children[i] if not Rind::Nodes.new([children[i]]).filter(path).empty?
			end
		end
	end

	# Creates a Rind::Nodes list of all siblings that proceed the
	# current node in the list of siblings. If an Xpath is provided
	# it will only return the nodes that match.
	def prev_siblings(path = nil)
		children = self.parent.children
		siblings = Rind::Nodes.new(children[0...children.index(self)])
		path.nil? ? siblings : siblings.filter(path)
	end

	# Creates a Rind::Nodes list of all siblings. If an Xpath is
	# provided it will only return the nodes that match.
	def siblings(path = nil)
		siblings = Rind::Nodes.new(self.parent.children.find_all{|child| not child.equal? self})
		path.nil? ? siblings : siblings.filter(path)
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
				return node if not Rind::Nodes.new([node]).filter(path).empty?
			end
			nil
		end
	end
end
