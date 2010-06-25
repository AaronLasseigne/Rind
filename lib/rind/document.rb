module Rind
	class Document
		include Equality

		attr_reader :base_namespace, :dom, :template, :type

		# === Parameter
		# _template_ = file system path to the template
		#
		# === Options
		# * _base_namespace_ = namespace
		#
		#   Allows you to provide a namespace to check before
		#   falling back to the default Rind namespace.
		# * _require_ = array of namespaces
		#
		#   All namespaces that should be rendered must be
		#   listed.
		# * _type_ = "xml" or "html"
		#
		#   This can be automatically detect based on the
		#   file extension. Unknown extensions will default
		#   to "xml".
		# === Example
		#  Rind::Document.new( "template.tpl", {
		#    :type           => "html",
		#    :base_namespace => "core",
		#    :require        => ["forms","photos"]
		#  })
		def initialize(template, options = {})
			@template = template
			raise 'No such template.' if not File.file? @template

			if options[:type]
				@type = options[:type]
			else
				@type = case File.extname(@template)
				when '.html', '.htm'
					'html'
				else
					'xml'
				end
			end

			if options[:base_namespace]
				@base_namespace = options[:base_namespace]
			else
				@base_namespace = ['rind', @type].join(':')
			end

			@dom = Rind.parse(@template, @type, @base_namespace, options[:require])
		end

		# Renders the Document in place. This will recursively call
		# <tt>render!</tt> on all the Document contents.
		def render!
			@dom.collect{|node| node.respond_to?(:render!) ? node.render! : node}.join('')
		end

		# Return the root node of the Document.
		def root
			@dom.each do |node|
				return node if not node.is_a? Rind::DocType
			end
		end

		def to_s
			@dom.to_s
		end

		# Xpath search of the root node that returns a list of matching nodes.
		def xpath_search(path)
			root.xs(path)
		end
		alias :xs :xpath_search

		# Xpath search returning only the first matching node in the list.
		def xpath_search_first(path)
			root.xsf(path)
		end
		alias :xsf :xpath_search_first
	end
end
