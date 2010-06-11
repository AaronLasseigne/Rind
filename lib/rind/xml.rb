module Rind
	# Rind::Xml will dynamically create any XML element.
	module Xml
		def self.const_missing(full_class_name, options={}) # :nodoc:
			klass = Class.new(Element) do
			  # <b>Parent:</b> Element
				# === Example
				#  Rind::Xml::Foo.new(
				#    :attributes => {:id => "bar"},
				#    :children   => "Hello World!"
				#  )
				def initialize(options={})
					super(options)
				end

				def expanded_name # :nodoc:
					if @namespace_name.nil? or @namespace_name == '' or @namespace_name =~ /^(?:rind:)?xml/
						@local_name
					else
						[@namespace_name, @local_name].join(':')
					end
				end
			end
			const_set full_class_name, klass
			klass
		end
	end
end
