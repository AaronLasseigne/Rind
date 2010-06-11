require 'test/unit'
require 'rind'

class NodesTest < Test::Unit::TestCase
	def setup
		@p_one = Rind::Html::P.new(:attributes => {:class => '1'})
		@p_two = Rind::Html::P.new(:attributes => {:class => '2'})
		@br_one = Rind::Html::Br.new(:attributes => {:class => '1'})
		@br_two = Rind::Html::Br.new(:attributes => {:class => '2'})
		@nodes = Rind::Nodes.new([@p_one, @p_two, @br_one, @br_two])
	end

	def test_filter
		assert_equal(@nodes.filter('br'), [@br_one, @br_two])
	end
end
