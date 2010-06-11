# Note: These functions are not available for the root node in a tree.
module Manipulate
	# Calls {Rind::Children::insert}[link:classes/Rind/Children.html#insert]
	# to add nodes after <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[0].insert_after('d', 'e') => ['a', 'd', 'e', 'b', 'c']
	def insert_after(*nodes)
		children = self.parent.children
		children.insert(children.index(self)+1, *nodes)
	end

	# Calls {Rind::Children::insert}[link:classes/Rind/Children.html#insert]
	# to add nodes before <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[2].insert_after('d', 'e') => ['a', 'b', 'd', 'e', 'c']
	def insert_before(*nodes)
		children = self.parent.children
		children.insert(children.index(self), *nodes)
	end

	# Calls {Rind::Children::delete}[link:classes/Rind/Children.html#delete]
	# on <tt>self</tt>.
	# === Example
	#  nodes = ['a', 'b', 'c']
	#  nodes[1].delete => 'b'
	def remove
		self.parent.children.delete(self)
	end
end
