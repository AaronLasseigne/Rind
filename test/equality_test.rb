require 'test/unit'
require 'rind'

class EqualityTest < Test::Unit::TestCase
	def setup
		@a = Rind::Comment.new('hello world')
		@b = Rind::Comment.new('hello world')
	end

	def test_double_equal
		assert_equal(@a, @b)
		assert_equal(@a, @b.to_s)
	end

	def test_eql
		assert(@a.eql?(@b))
		assert(! @a.eql?('<!--hello world-->'))
	end
end
