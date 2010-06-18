module Node
	include Manipulate
	include Traverse
	include Xpath

	attr_accessor :parent

	def is_leaf?
		if self.respond_to? :children
			self.children.empty? ? true : false
		else
			true
		end
	end

	def is_root?
		self.parent.nil? ? true : false
	end
end
