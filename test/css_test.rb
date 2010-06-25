require 'test/unit'
require 'rind'

class CssTest < Test::Unit::TestCase
	def test_node_test
		a = Rind::Html::A.new
		b = Rind::Html::B.new
		c = Rind::Html::C.new
		d = Rind::Html::D.new
		b.children.push(c, d)
		a.children.push(b)

		assert_equal(a.cs('*'), [a, b, c, d])
		assert_equal(a.cs('c'), [c])
		assert_equal(a.cs('f'), [])
	end

	def test_namespace
		a1 = Rind::Html::A.new
		a2 = Rind::Html::A.new( :namespace_name => 'foo' )
		b = Rind::Html::B.new

		assert_equal(a2.cs('foo|a'), [a2])
		assert_equal(a1.cs('foo|a'), [])

		assert_equal(a1.cs('*|a'), [a1])
		assert_equal(a2.cs('*|a'), [a2])
		assert_equal(b.cs('*|a'), [])

		assert_equal(a1.cs('|a'), [a1])
		assert_equal(a2.cs('|a'), [])
	end

	# axis tests

	def test_descendants
		a = Rind::Html::A.new
		b = Rind::Html::B.new
		c1 = Rind::Html::C.new(:attributes => {:id => 1})
		c2 = Rind::Html::C.new(:attributes => {:id => 2})
		d = Rind::Html::D.new
		b.children.push(c1, c2, d)
		a.children.push(b)

		assert_equal(a.cs('a c'), [c1, c2])
		assert_equal(a.cs('a foo'), [])
	end

	def test_child
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		a.children.push(b1, b2)

		assert_equal(a.cs('a > b'), [b1, b2])
		assert_equal(a.cs('a > foo'), [])
	end

	def test_immediately_previous
		a = Rind::Html::A.new
		b = Rind::Html::B.new
		c = Rind::Html::C.new
		a.children.push(b, c)

		assert_equal(a.cs('b + c'), [c])
		assert_equal(a.cs('foo + c'), [])
	end

	def test_preceded_by
		a = Rind::Html::A.new
		b = Rind::Html::B.new
		c = Rind::Html::C.new
		d = Rind::Html::D.new
		a.children.push(b, c, d)

		assert_equal(a.cs('b ~ d'), [d])
		assert_equal(a.cs('foo ~ d'), [])
	end

	# predicate tests

	def test_attributes
		a = Rind::Html::A.new(:attributes => {
			:id    => 'foo',
			:class => 'hello world',
			:lang  => 'en-US',
			:lang2 => 'en'
		})

		assert_equal(a.cs('a[class]'), [a])
		assert_equal(a.cs('a[bar]'), [])

		assert_equal(a.cs('a[class="hello world"]'), [a])
		assert_equal(a.cs('a[class="bar"]'), [])

		assert_equal(a.cs('a[class~="hello"]'), [a])
		assert_equal(a.cs('a[class~="world"]'), [a])
		assert_equal(a.cs('a[class~="bar"]'), [])

		assert_equal(a.cs('a[class^="he"]'), [a])
		assert_equal(a.cs('a[class^="bar"]'), [])

		assert_equal(a.cs('a[class$="ld"]'), [a])
		assert_equal(a.cs('a[class$="bar"]'), [])

		assert_equal(a.cs('a[class*="lo wo"]'), [a])
		assert_equal(a.cs('a[class*="bar"]'), [])

		assert_equal(a.cs('a[lang|="en"]'), [a])
		assert_equal(a.cs('a[lang2|="en"]'), [a])
		assert_equal(a.cs('a[class|="en"]'), [])

		assert_equal(a.cs('a#foo'), [a])
		assert_equal(a.cs('a#bar'), [])

		assert_equal(a.cs('a.hello'), [a])
		assert_equal(a.cs('a.world'), [a])
		assert_equal(a.cs('a.bar'), [])

		assert_equal(a.cs('.hello'), [a])
	end

	def test_structural_pseudo_classes_root
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		b3 = Rind::Html::B.new(:attributes => {:id => 3})
		b4 = Rind::Html::B.new(:attributes => {:id => 4})
		a.children.push(b1, b2, b3, b4)

		assert_equal(a.cs('a:root'), [a])
		assert_equal(a.cs('b:root'), [])
	end

	def test_structural_pseudo_classes_nth_child
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		b3 = Rind::Html::B.new(:attributes => {:id => 3})
		b4 = Rind::Html::B.new(:attributes => {:id => 4})
		a.children.push(b1, b2, b3, b4)

		assert_equal(a.cs('b:nth-child(2)'), [b2])
		assert_equal(a.cs('b:nth-child(odd)'), [b1, b3])
		assert_equal(a.cs('b:nth-child(even)'), [b2, b4])
		assert_equal(a.cs('b:nth-child(2n + 1)'), [b1, b3])
		assert_equal(a.cs('b:nth-child(2n)'), [b2, b4])
		assert_equal(a.cs('b:nth-child(0n+3)'), [b3])
		assert_equal(a.cs('b:nth-child(0)'), [])
		assert_equal(a.cs('b:nth-child(1)'), [b1])
		assert_equal(a.cs('b:nth-child(4)'), [b4])

		assert_equal(a.cs('b:nth-last-child(2)'), [b3])
		assert_equal(a.cs('b:nth-last-child(2n + 1)'), [b2, b4])
		assert_equal(a.cs('b:nth-last-child(2n)'), [b1, b3])
		assert_equal(a.cs('b:nth-last-child(0n+3)'), [b2])
		assert_equal(a.cs('b:nth-last-child(0)'), [])
		assert_equal(a.cs('b:nth-last-child(1)'), [b4])
		assert_equal(a.cs('b:nth-last-child(4)'), [b1])

		assert_equal(a.cs('b:first-child'), [b1])

		assert_equal(a.cs('b:last-child'), [b4])
	end

	def test_structural_pseudo_classes_nth_of_type
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		b3 = Rind::Html::B.new(:attributes => {:id => 3})
		c1 = Rind::Html::C.new(:attributes => {:id => 1})
		c2 = Rind::Html::C.new(:attributes => {:id => 2})
		d1 = Rind::Html::D.new(:attributes => {:id => 1})
		d2 = Rind::Html::D.new(:attributes => {:id => 2})
		a.children.push(b1, c1, d1, b2, c2, b3, d2)

		assert_equal(a.cs('b:nth-of-type(2)'), [b2])
		assert_equal(a.cs('b:nth-of-type(odd)'), [b1, b3])
		assert_equal(a.cs('c:nth-of-type(even)'), [c2])
		assert_equal(a.cs('b:nth-of-type(2n + 1)'), [b1, b3])
		assert_equal(a.cs('c:nth-of-type(2n)'), [c2])
		assert_equal(a.cs('b:nth-of-type(0n+3)'), [b3])
		assert_equal(a.cs('b:nth-of-type(0)'), [])
		assert_equal(a.cs('b:nth-of-type(1)'), [b1])
		assert_equal(a.cs('b:nth-of-type(3)'), [b3])

		assert_equal(a.cs('b:nth-last-of-type(2)'), [b2])
		assert_equal(a.cs('b:nth-last-of-type(2n + 1)'), [b1, b3])
		assert_equal(a.cs('b:nth-last-of-type(2n)'), [b2])
		assert_equal(a.cs('b:nth-last-of-type(0n+3)'), [b1])
		assert_equal(a.cs('b:nth-last-of-type(0)'), [])
		assert_equal(a.cs('b:nth-last-of-type(1)'), [b3])
		assert_equal(a.cs('b:nth-last-of-type(3)'), [b1])

		assert_equal(a.cs('d:first-of-type'), [d1])

		assert_equal(a.cs('d:last-of-type'), [d2])
	end

	def test_structural_pseudo_classes_only
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		c = Rind::Html::C.new()
		d1 = Rind::Html::D.new(:attributes => {:id => 1})
		d2 = Rind::Html::D.new(:attributes => {:id => 2})
		e = Rind::Html::E.new()
		b1.children.push(c)
		b2.children.push(d1, d2, e)
		a.children.push(b1, b2)

		assert_equal(a.cs('c:only-child'), [c])
		assert_equal(a.cs('b:only-child'), [])

		assert_equal(a.cs('c:only-of-type'), [c])
		assert_equal(a.cs('e:only-of-type'), [e])
		assert_equal(a.cs('d:only-of-type'), [])
	end

	def test_structural_pseudo_classes_only
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		b3 = Rind::Html::B.new(:attributes => {:id => 3})
		c = Rind::Html::C.new()
		b1.children.push(c)
		a.children.push(b1, b2, b3)

		assert_equal(a.cs('b:empty'), [b2, b3])
		assert_equal(a.cs('c:empty'), [c])
		assert_equal(a.cs('a:empty'), [])
	end

	def test_structural_pseudo_classes_checked
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2, :checked => 'checked'})
		b3 = Rind::Html::B.new(:attributes => {:id => 3, :CHECKED => ''})
		c1 = Rind::Html::C.new(:attributes => {:id => 1, :selected => 'selected'})
		c2 = Rind::Html::C.new(:attributes => {:id => 2, :SELECTED => ''})
		a.children.push(b1, b2, b3)

		assert_equal(a.cs('b:checked'), [b2, b3])
		assert_equal(c1.cs('c:checked'), [c1])
		assert_equal(c2.cs('c:checked'), [c2])
		assert_equal(a.cs('a:checked'), [])
	end

	def test_structural_pseudo_classes_not
		a = Rind::Html::A.new
		b1 = Rind::Html::B.new(:attributes => {:id => 1})
		b2 = Rind::Html::B.new(:attributes => {:id => 2})
		a.children.push(b1, b2)

		assert_equal(a.cs('b:not(#1)'), [b2])
		assert_equal(a.cs('*:not(b)'), [a])
		assert_equal(a.cs('b:not(:nth-child(2))'), [b1])
		assert_equal(a.cs('b:not([id="1"])'), [b2])
		assert_equal(a.cs('b:not(:empty)'), [])
	end

	def test_multiple_predicates
		a = Rind::Html::A.new(:attributes => {:id => 'foo', :class => 'hello world'})

		assert_equal(a.cs('a[class][id="foo"]'), [a])
		assert_equal(a.cs('a[class][id="bar"]'), [])
	end
end
