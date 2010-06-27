# Note: These functions are not available for the root node in a tree.
module Manipulate
	# Calls Rind::Children::insert to add nodes after <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[0].insert_after('d', 'e') => ['a', 'd', 'e', 'b', 'c']
	def insert_after(*nodes)
		children = self.parent.children
		children.insert(children.exact_index(self) + 1, *nodes)
	end

	# Calls Rind::Children::insert to add nodes before <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[2].insert_after('d', 'e') => ['a', 'b', 'd', 'e', 'c']
	def insert_before(*nodes)
		children = self.parent.children
		children.insert(children.exact_index(self), *nodes)
	end

	# Removes <tt>self</tt> from siblings and returns it.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[1].remove => 'b'
	#  nodes => ['a', 'c']
	def remove
		self.parent.children.delete_at(self.parent.children.exact_index(self))
	end

	# Replace <tt>self</tt> with new nodes.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[1].replace('y', 'z') => ['a', 'y', 'z', 'c']
	def replace(*nodes)
		children = self.parent.children

		index = children.exact_index(self)
		children.delete_at(index)

		children.insert(index, *nodes)
	end

	# Swap <tt>self</tt> from one node set with a <tt>node</tt> from another node set.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[1].swap('d') => ['a', 'd', 'c']
	#
	#  abc = ['a', 'b', 'c']
	#  xyz = ['x', 'y', 'z']
	#  abc[1].swap(xyz[1]) => ['a', 'y', 'c']
	#  xyz => ['x', 'b', 'z']
	def swap(node)
		self_children = self.parent.children
		node_children = node.parent.children

		self_index = self_children.exact_index(self)
		node_index = node_children.exact_index(node)

		self_children.delete_at(self_index)
		node_children.delete_at(node_index)

		self_children.insert(self_index, node)
		node_children.insert(node_index, self)

		self_children
	end
end
