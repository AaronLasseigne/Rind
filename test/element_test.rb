require 'test/unit'
require 'rind'

class ElementTest < Test::Unit::TestCase
  def setup
    @element = Rind::Element.new(
			:attributes => {:class => "foo", :id => 'bar'},
			:children   => ['This is some text!', Rind::Element.new()]
		)
  end

	def test_attribute_parsing
    element2 = Rind::Element.new(
			:attributes => 'class="foo" id="bar"',
			:children   => ['This is some text!', Rind::Element.new()]
		)
		assert_equal(element2, @element)

		element3 = Rind::Element.new(
			:attributes => 'id=foo class="hi bye" selected one=\'1\' other="\'first\' second" http-equiv="boo" type="text/css"'
		)
		assert_equal(element3[:id], 'foo')
		assert_equal(element3[:class], 'hi bye')
		assert_equal(element3[:selected], '')
		assert_equal(element3[:one], '1')
		assert_equal(element3[:other], "'first' second")
		assert_equal(element3['http-equiv'], "boo")
		assert_equal(element3[:type], "text/css")
	end

  def test_accessor
		# get
    assert_equal(@element[], {'class' => 'foo', 'id' => 'bar'})
    assert_equal(@element[:id], 'bar')
    assert_equal(@element['class'], 'foo')

		# set
    @element[:class] = 'hi'
    assert_equal(@element[:class], 'hi')
    @element['id'] = 'second'
    assert_equal(@element[:id], 'second')
  end

  def test_local_name
    assert_equal(@element.local_name, 'element')
  end

  def test_namespace
    assert_equal(@element.namespace_name, 'rind')
  end

	def test_expanded_name
		assert_equal(@element.expanded_name, 'element')
		assert_equal(Rind::Element.new(:namespace_name => 'test').expanded_name, 'test:element')
	end

  def test_to_s
    assert_equal(@element.to_s, '<element class="foo" id="bar">This is some text!<element /></element>')
  end
end
