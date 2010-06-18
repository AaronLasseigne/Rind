require 'test/unit'
require 'rind'

class NodeTest < Test::Unit::TestCase
  def test_parent
		node1 = Rind::Element.new
		node2 = Rind::Element.new
		node1.children.push(node2)

    assert_same(node2.parent, node1)
		assert_nil(node1.parent)
  end
end
