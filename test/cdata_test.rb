require 'test/unit'
require 'rind'

class CdataTest < Test::Unit::TestCase
	def test_to_s
		cdata = Rind::Cdata.new('foo')
		assert_equal(cdata.to_s, '<![CDATA[foo]]>')
	end
end
