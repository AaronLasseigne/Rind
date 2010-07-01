module Node
	include Manipulate
	include Traverse
	include Xpath
	include Css

	attr_accessor :parent

	# Returns true if the node has no children.
	def is_leaf?
		not self.respond_to? :children or self.children.empty?
	end

	# Returns true if the node is the topmost node.
	def is_root?
		self.parent.nil?
	end
end
