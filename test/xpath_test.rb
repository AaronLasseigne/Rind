require 'test/unit'
require 'rind'

class XpathTest < Test::Unit::TestCase
	def setup
		@a = Rind::Html::A.new
		@b1 = Rind::Html::B.new(:attributes => {:id => '1', :class => '1'})
		@b2 = Rind::Html::B.new(:attributes => {:id => '2', :class => '2'})
		@b3 = Rind::Html::B.new(:attributes => {:id => '3', :type => 'text/css'})
		@c1 = Rind::Html::C.new()
		@c2 = Rind::Html::C.new()
		@c3 = Rind::Html::C.new()
		@comment = Rind::Comment.new('comment')
		@pi = Rind::ProcessingInstruction.new('pi')
		@text = Rind::Text.new('text')
		@b1.children.push(@c1)
		@b2.children.push(@c2, @c3)
		@b3.children.push(@comment, @pi, @text)
		@a.children.push(@b1, @b2, @b3)
	end

  def test_s
		assert_equal(@c1.xs('/a'), [@a])

		assert_equal(@a.xs('//c'), [@c1, @c2, @c3])
		assert_equal(@a.xs('//parent::b/c'), [@c1, @c2, @c3])

		assert_equal(@c2.xs('..'), [@b2] )

		assert_equal(@c2.xs('.'), [@c2] )

		assert_equal(@a.xs('foo'), [])
  end

	def test_s_axis
		assert_equal(@c1.xs('ancestor::*'), [@b1, @a])

		assert_equal(@c1.xs('ancestor-or-self::*'), [@c1, @b1, @a])

		assert_equal(@a.xs('child::*'), [@b1, @b2, @b3])

		assert_equal(@a.xs('descendant::*'), [@b1, @b2, @b3, @c1, @c2, @c3, @comment, @pi])

		assert_equal(@a.xs('descendant-or-self::*'), [@a, @b1, @b2, @b3, @c1, @c2, @c3, @comment, @pi])

		assert_equal(@b2.xs('following-sibling::*'), [@b3])

		assert_equal(@b3.xs('parent::*'), [@a])

		assert_equal(@b2.xs('preceding-sibling::*'), [@b1])

		assert_equal(@a.xs('self::*'), [@a])
	end

	def test_s_node_test
		assert_equal(@a.xs('//*'), [@b1, @b2, @b3, @c1, @c2, @c3, @comment, @pi])

		assert_equal(@a.xs('//comment()'), [@comment])

		assert_equal(@a.xs('//node()'), [@b1, @b2, @b3, @c1, @c2, @c3, @comment, @pi, @text])

		assert_equal(@a.xs('//processing-instruction()'), [@pi])

		assert_equal(@a.xs('//text()'), [@text])

		assert_equal(@a.xs('b'), [@b1, @b2, @b3])
	end

	def test_s_attribute
		assert_equal(@a.xs('b[@class="1"]'), [@b1])

		assert_equal(@a.xs('//b[@type="text/css"]'), [@b3])
	end

	def test_s_position
		assert_equal(@b2.xs('c[2]'), [@c3])

		assert_equal(@a.xs('b[position()=1]'), [@b1])

		assert_equal(@a.xs('b[last()]'), [@b3])
	end

	def test_sf
		assert_same(@a.xsf('b'), @b1)
		assert_nil(@a.xsf('foo'))
	end
end
