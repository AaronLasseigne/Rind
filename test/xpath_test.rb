require 'test/unit'
require 'rind'

class XpathTest < Test::Unit::TestCase
	def setup
		@a = Rind::Html::A.new
		@b1 = Rind::Html::B.new(:attributes => {:id => '1', :class => '1'})
		@b2 = Rind::Html::B.new(:attributes => {:id => '2', :class => '2'})
		@b3 = Rind::Html::B.new(:attributes => {:id => '3'})
		@c1 = Rind::Html::C.new(:attributes => {:id => '1', :type => 'text/css'})
		@c2 = Rind::Html::C.new(:attributes => {:id => '2'})
		@b1.children.push(@c1)
		@b2.children.push(@c2)
		@a.children.push(@b1, @b2, @b3)
	end

  def test_s
		assert_equal(@a.s('b'), [@b1, @b2, @b3])

		assert_equal(@c1.s('/a'), [@a])

		assert_equal(@a.s('//c'), [@c1, @c2])

		assert_equal(@c2.s('..'), [@b2] )

		assert_equal(@c2.s('.'), [@c2] )

		assert_equal(@a.s('foo'), [])
  end

	def test_s_attribute
		assert_equal(@a.s('b[@class="1"]'), [@b1])

		assert_equal(@a.s('//c[@type="text/css"]'), [@c1])
	end

	def test_s_position
		assert_equal(@a.s('b[2]'), [@b2])

		assert_equal(@a.s('b[position()=1]'), [@b1])

		assert_equal(@a.s('b[last()]'), [@b3])
	end

	def test_sf
		assert_same(@a.sf('b'), @b1)
		assert_nil(@a.sf('foo'))
	end
end
