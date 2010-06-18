module Node
	include Manipulate
	include Traverse
	include Xpath

	attr_accessor :parent

	# Returns true is the node has no children.
	def is_leaf?
		if self.respond_to? :children
			self.children.empty? ? true : false
		else
			true
		end
	end

	# Returns true if the node is the topmost node.
	def is_root?
		self.parent.nil? ? true : false
	end
end
