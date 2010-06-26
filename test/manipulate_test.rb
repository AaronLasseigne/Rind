require 'test/unit'
require 'rind'

class ManipulateTest < Test::Unit::TestCase
	def setup
		@a = Rind::Html::A.new()
		@b1 = Rind::Html::B.new()
		@b2 = Rind::Html::B.new()
		@a.children.push(@b1, @b2)
	end

	def test_insert_after
		assert_equal(@a.children[1].insert_after('foo'), [@b1, @b2, 'foo'])
	end

	def test_insert_before
		assert_equal(@a.children[1].insert_before('foo'), [@b1, 'foo', @b2])
	end

	def test_remove
		assert_equal(@a.children[1].remove, @b2)
		assert(@a.children.empty?)
	end
end
