require 'test/unit'
require 'rind'

class ChildrenTest < Test::Unit::TestCase
	def setup
		@parent = Rind::Html::Html.new()
		@one = Rind::Html::P.new(:attributes => {:id => '1'})
		@two = Rind::Html::P.new(:attributes => {:id => '2'})
		@three = Rind::Html::P.new(:attributes => {:id => '3'})
		@children = Rind::Children.new(@parent, @one, @two, @three)
	end

	def test_delete
		# normal
		child = @children.delete(@one)
		assert_same(child, @one)
		assert_nil(child.parent)
		assert_equal(@children.length, 2)

		# item not found
		child = @children.delete('a')
		assert_nil(child)

		# item not found with block
		child = @children.delete('a') {'not found'}
		assert_equal(child, 'not found')
	end

	# testing the clearing of the parent using internal wrapper
	def test_pop
		child = @children.pop
		assert_same(child, @three)
		assert_nil(child.parent)
		assert_equal(@children.length, 2)
	end

	# testing the addition of the parent using internal wrapper
	def test_push
		children = Rind::Children.new(@parent)
		children.push(@one, @two, @three)
		assert_equal(children, @children)
		children.each do |child|
			assert_same(child.parent, @parent)
		end
	end

	def test_to_s
		assert_equal(@children.to_s, '<p id="1"></p><p id="2"></p><p id="3"></p>')
	end
end
