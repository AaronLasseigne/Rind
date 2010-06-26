require 'test/unit'
require 'rind'

class XmlTest < Test::Unit::TestCase
  def test_to_s
		# no children
    a_tag = Rind::Xml::A.new()
    assert_equal(a_tag.to_s, '<a />')

		# with children
    b_tag = Rind::Xml::B.new(:children => a_tag)
    assert_equal(b_tag.to_s, '<b><a /></b>')
  end
end
