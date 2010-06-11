require 'test/unit'
require 'rind'

class CommentTest < Test::Unit::TestCase
	def test_to_s
		comment = Rind::Comment.new('foo')
		assert_equal(comment.to_s, '<!--foo-->')
	end
end
