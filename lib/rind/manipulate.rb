# Note: These functions are not available for the root node in a tree.
module Manipulate
	# Calls Rind::Children::insert to add nodes after <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[0].insert_after('d', 'e') => ['a', 'd', 'e', 'b', 'c']
	def insert_after(*nodes)
		children = self.parent.children
		children.insert(children.exact_index(self)+1, *nodes)
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
end
