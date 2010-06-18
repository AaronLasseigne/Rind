require 'test/unit'
require 'rind'

class NodeTest < Test::Unit::TestCase
	def setup
		@node1 = Rind::Element.new
		@node2 = Rind::Element.new
		@node1.children.push(@node2)
	end

  def test_parent
    assert_same(@node2.parent, @node1)
		assert_nil(@node1.parent)
  end

	def test_is_leaf?
		assert(!@node1.is_leaf?)
		assert(@node2.is_leaf?)
	end

	def test_is_root?
		assert(@node1.is_root?)
		assert(!@node2.is_root?)
	end
end
