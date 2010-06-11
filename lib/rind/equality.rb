module Equality
	def ==(item)
		self.to_s == item.to_s
	end

	def eql?(item)
		item.instance_of?(self.class) && self == item
	end
end
