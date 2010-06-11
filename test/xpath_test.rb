require 'test/unit'
require 'rind'

class XpathTest < Test::Unit::TestCase
	def setup
		@br_one = Rind::Html::Br.new(:attributes => {:id => 'br_one', :class => '1'})
		@br_two = Rind::Html::Br.new(:attributes => {:id => 'br_two', :class => '2'})
		@br_three = Rind::Html::Br.new()
		@p_one = Rind::Html::P.new(:attributes => {:class => '1'}, :children => [@br_one, @br_two, @br_three])
	end

  def test_s
		assert_equal(@p_one.s('br'), [@br_one, @br_two, @br_three])

		# attribute tests
		assert_equal(@p_one.s('br[@class="1"]'), [@br_one])

		# position tests
		assert_equal(@p_one.s('br[2]'), [@br_two])
		assert_equal(@p_one.s('br[position()=1]'), [@br_one])
		assert_equal(@p_one.s('br[last()]'), [@br_three])
  end

	def test_sf
		assert_same(@p_one.sf('br'), @br_one)
	end
end
