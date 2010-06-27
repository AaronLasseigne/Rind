require 'test/unit'
require 'rind'

class ManipulateTest < Test::Unit::TestCase
	def setup
		@a = Rind::Html::A.new()
		@b1 = Rind::Html::B.new()
		@b2 = Rind::Html::B.new()
		@b3 = Rind::Html::B.new()
		@a.children.push(@b1, @b2, @b3)
	end

	def test_insert_after
		assert_equal(@a.children[1].insert_after('foo'), [@b1, @b2, 'foo', @b3])
	end

	def test_insert_before
		assert_equal(@a.children[1].insert_before('foo'), [@b1, 'foo', @b2, @b3])
	end

	def test_remove
		assert_equal(@a.children[1].remove, @b2)
		assert_equal(@a.children, [@b1, @b3])
	end

	def test_replace
		c1 = Rind::Html::C.new()
		c2 = Rind::Html::C.new()

		assert_equal(@a.children[0].replace(c1, c2), [c1, c2, @b2, @b3])
	end

	def test_swap
		z = Rind::Html::Z.new()
		y1 = Rind::Html::Y.new()
		y2 = Rind::Html::Y.new()
		z.children.push(y1, y2)

		assert_equal(@a.children[1].swap(y2), [@b1, y2, @b3])
		assert_equal(z.children, [y1, @b2])
	end
end
