require 'test/unit'
require 'rind'

class TraverseTest < Test::Unit::TestCase
  def setup
    @root = Rind::Document.new('files/traverse_test.html').root
  end

  def test_ancestors
    assert_equal(@root.down('f').ancestors, [@root.down('d'), @root.down('c'), @root.down('b'), @root])
    assert_equal(@root.down('f').ancestors('c'), [@root.down('c')])
		assert_equal(@root.ancestors, [])
  end

  def test_descendants
    assert_equal(@root.down('c').descendants, [@root.down('d'), @root.down('h'), @root.down('i'), @root.down('e'), @root.down('f'), @root.down('g'), @root.down('j')])
    assert_equal(@root.descendants('f'), [@root.down('f')])
		assert_equal(@root.down('e').descendants, [])
  end

  def test_down
    assert_equal(@root.down.name, 'b')
    assert_equal(@root.down('f').name, 'f')
		assert_nil(Rind::Element.new().down)
  end

  def test_next
    assert_same(@root.down('f').next, @root.down('g'))
    assert_same(@root.down('e').next('g'), @root.down('g'))
		assert_nil(@root.down.next)
  end

  def test_next_siblings
    assert_equal(@root.down('f').next_siblings, [@root.down('g')])
    assert_equal(@root.down('e').next_siblings('g'), [@root.down('g')])
		assert_equal(@root.down.next_siblings, [])
  end

  def test_prev
    assert_same(@root.down('f').prev, @root.down('e'))
    assert_same(@root.down('g').prev('e'), @root.down('e'))
		assert_nil(@root.down.prev)
  end

  def test_prev_siblings
    assert_equal(@root.down('f').prev_siblings, [@root.down('e')])
    assert_equal(@root.down('g').prev_siblings('e'), [@root.down('e')])
		assert_equal(@root.down.prev_siblings, [])
  end

  def test_siblings
    assert_equal(@root.down('f').siblings, [@root.down('e'), @root.down('g')])
    assert_equal(@root.down('f').siblings('e'), [@root.down('e')])
		assert_equal(@root.down.siblings, [])
  end

  def test_up
    assert_same(@root.down('f').up, @root.down('d'))
    assert_same(@root.down('f').up('b'), @root.down('b'))
		assert_nil(@root.up)
  end
end
