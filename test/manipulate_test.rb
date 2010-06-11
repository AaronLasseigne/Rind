require 'test/unit'
require 'rind'

class ManipulateTest < Test::Unit::TestCase
	def setup
		@p = Rind::Html::P.new(:children => ['This is some text!'])
		@br = Rind::Html::Br.new()
		@hr = Rind::Html::Hr.new()
	end

	def test_insert_after
		assert_equal(@p.children.first.insert_after(@br, @hr), ['This is some text!', @br, @hr])
	end

	def test_insert_before
		assert_equal(@p.children.first.insert_before(@br, @hr), [@br, @hr, 'This is some text!'])
	end

	def test_remove
		assert_equal(@p.children.first.remove, 'This is some text!')
		assert(@p.children.empty?)
	end
end
