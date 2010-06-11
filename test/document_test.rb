require 'test/unit'
require 'rind'

class DocumentTest < Test::Unit::TestCase
	def setup
		@doc = Rind::Document.new('files/document_test.html')
	end

	def test_template_failure
		assert_raise(RuntimeError) do
			Rind::Document.new('files/missing_template.html')
		end
	end

	def test_type
		assert_equal(@doc.type, 'html')
		assert_equal(Rind::Document.new('files/document_test.html', {:type => 'xml'}).type, 'xml' )
	end

	def test_root
		assert_equal(@doc.root.name, 'html')
	end
end
