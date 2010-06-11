require 'test/unit'
require 'rind'

class HtmlTest < Test::Unit::TestCase
	def test_expanded_name
		assert_equal(Rind::Html::Br.new().expanded_name, 'br')
	end

	def test_to_s
		# self closing tag
		assert_equal(Rind::Html::Br.new().to_s, '<br />')

		# requires separate closing tag
		assert_equal(Rind::Html::P.new().to_s, '<p></p>')
	end
end
