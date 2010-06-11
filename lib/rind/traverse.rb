module Traverse
	attr_accessor :parent

	# Creates a Rind::Nodes list of all ancestors. If an Xpath
	# is provided it will only return the nodes that match.
	def ancestors(path = nil)
		if not self.parent.nil?
			ancestors = Rind::Nodes.new([self.parent])

			parent_ancestors = self.parent.ancestors
			ancestors.push(*parent_ancestors) if not parent_ancestors.nil?

			path.nil? ? ancestors : ancestors.filter(path)
		end
	end

	# Creates a Rind::Nodes list of all descendants. If an Xpath
	# is provided it will only return the nodes that match.
	def descendants(path = nil)
		if self.respond_to? :children and not self.children.empty?
			descendants = Rind::Nodes.new(self.children)

			self.children.each do |child|
				child_descendants = child.descendants
				descendants.push(*child_descendants) if not child_descendants.nil?
			end

			path.nil? ? descendants : descendants.filter(path)
		end
	end

	# Returns the first descendant node. If an Xpath is provided
	# it will return the first one that matches.
	def down(path = nil)
		descendants = self.descendants(path)
		descendants.first if not descendants.nil?
	end

	# Returns the first sibling that follows the current node in
	# the list of siblings. If an Xpath is provided it will return
	# the first one that matches.
	def next(path = nil)
		siblings = self.next_siblings(path)
		siblings.first if not siblings.nil?
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
		siblings = self.prev_siblings(path)
		siblings.last if not siblings.nil?
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
		ancestors = self.ancestors(path)
		ancestors.first if not ancestors.nil?
	end
end
