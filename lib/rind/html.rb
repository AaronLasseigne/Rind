module Rind
	# Rind::Html will dynamically create any standard (or not) HTML element.
	module Html
		def self.const_missing(full_class_name, options={}) # :nodoc:
			klass = Class.new(Element) do
				@@self_closing = ['br','hr','img','input','meta','link']

			  # <b>Parent:</b> Element
				# === Example
				#  Rind::Html::A.new(
				#    :attributes => {:href => "http://github.com"},
				#    :children   => "GitHub"
				#  )
				def initialize(options={})
					super(options)
				end

				def expanded_name # :nodoc:
					if @namespace_name.nil? or @namespace_name == '' or @namespace_name =~ /^(?:rind:)?html/
						@local_name
					else
						[@namespace_name, @local_name].join(':')
					end
				end

				def to_s # :nodoc:
					attrs = @attributes.collect{|k,v| "#{k}=\"#{v}\""}.join(' ')
					attrs = " #{attrs}" if not attrs.empty?

					if @@self_closing.include? @local_name
						"<#{self.expanded_name}#{attrs} />"
					else
						"<#{self.expanded_name}#{attrs}>#{@children}</#{self.expanded_name}>"
					end
				end
			end
			const_set full_class_name, klass
			klass
		end
	end
end
