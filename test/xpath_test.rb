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
		@comment = Rind::Comment.new('comment')
		@pi = Rind::ProcessingInstruction.new('pi')
		@text = Rind::Text.new('text')
		@b1.children.push(@c1)
		@b2.children.push(@c2)
		@b3.children.push(@comment, @pi, @text)
		@a.children.push(@b1, @b2, @b3)
	end

  def test_s
		assert_equal(@c1.s('/a'), [@a])

		assert_equal(@a.s('//c'), [@c1, @c2])

		assert_equal(@c2.s('..'), [@b2] )

		assert_equal(@c2.s('.'), [@c2] )

		assert_equal(@a.s('foo'), [])
  end

	def test_s_axis
		assert_equal(@c1.s('ancestor::*'), [@b1, @a])

		assert_equal(@c1.s('ancestor-or-self::*'), [@c1, @b1, @a])

		assert_equal(@a.s('child::*'), [@b1, @b2, @b3])

		assert_equal(@a.s('descendant::*'), [@b1, @b2, @b3, @c1, @c2, @comment, @pi])

		assert_equal(@a.s('descendant-or-self::*'), [@a, @b1, @b2, @b3, @c1, @c2, @comment, @pi])

		assert_equal(@b2.s('following-sibling::*'), [@b3])

		assert_equal(@b3.s('parent::*'), [@a])

		assert_equal(@b2.s('preceding-sibling::*'), [@b1])

		assert_equal(@a.s('self::*'), [@a])
	end

	def test_s_node_test
		assert_equal(@a.s('//*'), [@b1, @b2, @b3, @c1, @c2, @comment, @pi])

		assert_equal(@a.s('//comment()'), [@comment])

		assert_equal(@a.s('//node()'), [@b1, @b2, @b3, @c1, @c2, @comment, @pi, @text])

		assert_equal(@a.s('//processing-instruction()'), [@pi])

		assert_equal(@a.s('//text()'), [@text])

		assert_equal(@a.s('b'), [@b1, @b2, @b3])
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
