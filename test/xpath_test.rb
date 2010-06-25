require 'test/unit'
require 'rind'

class XpathTest < Test::Unit::TestCase
	def setup
		@br_one = Rind::Html::Br.new(:attributes => {:id => 'br_one', :class => '1'})
		@br_two = Rind::Html::Br.new(:attributes => {:id => 'br_two', :class => '2'})
		@br_three = Rind::Html::Br.new()
		@p_one = Rind::Html::P.new(:attributes => {:class => '1'}, :children => [@br_one, @br_two, @br_three])
	end

  def test_xpath_search
		assert_equal(@p_one.xs('br'), [@br_one, @br_two, @br_three])

		# attribute tests
		assert_equal(@p_one.xs('br[@class="1"]'), [@br_one])
		assert_equal(@p_one.xs('br[@class]'), [@br_one, @br_two])

		# position tests
		assert_equal(@p_one.xs('br[2]'), [@br_two])
		assert_equal(@p_one.xs('br[position()=1]'), [@br_one])
		assert_equal(@p_one.xs('br[last()]'), [@br_three])

		assert_equal(@p_one.xs('a'), [])
  end

	def test_xpath_search_first
		assert_same(@p_one.xsf('br'), @br_one)
		assert_nil(@p_one.xsf('a'))
	end
end
