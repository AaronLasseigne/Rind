require 'test/unit'
require 'rind'

class NodesTest < Test::Unit::TestCase
	def setup
		@p_one = Rind::Html::P.new(:attributes => {:class => '1'})
		@p_two = Rind::Html::P.new(:attributes => {:class => '2'})
		@br_one = Rind::Html::Br.new(:attributes => {:class => '1'})
		@br_two = Rind::Html::Br.new(:attributes => {:class => '2'})
		@nodes = Rind::Nodes[@p_one, @p_two, @br_one, @br_two]
	end

	def test_exact_index
		foo = Rind::Html::Foo.new

		assert_equal(@nodes.exact_index(@p_two), 1)
		assert_nil(@nodes.exact_index(foo))
	end

	def test_css_filter
		assert_equal(@nodes.cf('br'), [@br_one, @br_two])
		assert_equal(@nodes.cf('a'), [])
	end

	def test_xpath_filter
		assert_equal(@nodes.xf('br'), [@br_one, @br_two])
		assert_equal(@nodes.xf('a'), [])
	end
end
