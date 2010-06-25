module Rind
	class Nodes < Array
		# Returns the index of the first object in +self+ such that it is equal? to the node.
		def exact_index(node)
			self.each_index do |index|
				return index if self[index].equal?(node)
			end
			nil
		end

		# Return only the nodes that match the CSS selector provided.
		def css_filter(path)
			path = "self::#{path}"
			Nodes[*self.find_all{|node| not node.cs(path).empty?}]
		end
		alias :cf :css_filter

		# Return only the nodes that match the Xpath provided.
		def xpath_filter(path)
			# if the path doesn't have an axis then default to "self"
			if path !~ /^([.\/]|(.+?::))/
				path = "self::#{path}"
			end
			Nodes[*self.find_all{|node| not node.xs(path).empty?}]
		end
		alias :xf :xpath_filter
	end

	class Cdata
		include Equality
		include Node

		# Create a CDATA with <tt>content</tt> holding
		# the character data to contain.
		def initialize(content)
			@content = content
		end

		def to_s
			"<![CDATA[#{@content}]]>"
		end
	end

	class Comment
		include Equality
		include Node

		# Create a comment with <tt>content</tt> holding
		# the character data of the comment.
		def initialize(content)
			@content = content
		end

		def to_s
			"<!--#{@content}-->"
		end
	end

	class DocType
		include Equality

		# Create a Document Type Declaration with
		# +content+ holding the DTD identifiers.
		def initialize(content)
			@content = content
		end

		def to_s
			"<!DOCTYPE#{@content}>"
		end
	end

	class ProcessingInstruction
		include Equality
		include Manipulate
		include Traverse
		include Xpath

		# Create a processing instruction with
		# +content+ holding the character data.
		def initialize(content)
			@content = content
		end

		def to_s
			"<?#{@content}>"
		end
	end

	class Element
		include Equality
		include Node

		attr_reader :children, :local_name, :namespace_name
		alias :name :local_name
		alias :namespace :namespace_name

		# === Options
		# * _attributes_ = hash or string
		# * _children_   = array of nodes
		# === Examples
		#  Rind::Element.new(
		#    :attributes => { :id => "first", :class => "second" },
		#    :children   => [Rind::Element.new(), Rind::Element.new()]
		#  )
		#  Rind::Element.new(
		#    :attributes => 'id="first" class="second"',
		#    :children   => "Hello World!"
		#  )
		def initialize(options={})
			self.class.to_s =~ /^(?:([\w:]+)::)?(\w+)$/
			@namespace_name, @local_name = $1, $2.downcase
			@namespace_name.downcase!.gsub!(/::/, ':') if not @namespace_name.nil?

			@namespace_name = options[:namespace_name] if options[:namespace_name]

			@attributes = Hash.new
			if options[:attributes].is_a? Hash
				options[:attributes].each do |k,v|
					@attributes[k.to_s] = v.to_s
				end
			elsif options[:attributes].is_a? String
				# scan for attr=value|"value1 'value2'"|'"value1" value2' or attr by itself
				options[:attributes].scan(/([\w-]+)(?:=(\w+|"[^"]+?"|'[^']+?'))?/) do |name, value|
					@attributes[name] = value.nil? ? '' : value.sub(/\A(["'])([^\1]+)\1\z/, '\2')
				end
			end

			@children = Children.new(self, *options[:children])
		end

		# Get attributes or an attribute values.
		# === Examples
		#  e = Rind::Element.new(:attributes => {:id => "id_1", :class => "class_1"})
		#  e[]        => {"id"=>"id_1", "class"=>"class_1"}
		#  e[:id]     => "id_1"
		#  e['class'] => "class_1"
		def [](key = nil)
			key.nil? ? @attributes : @attributes[key.to_s]
		end

		# Set the value of an attribute.
		# === Examples
		#  e = Rind::Element.new(:attributes => {:id => "id_1", :class => "class_1"})
		#  e['id']   => "id_2"
		#  e[:class] => "class_2"
		def []=(key, value)
			@attributes[key.to_s] = value
		end

		# Get the full name of the Element.
		# === Examples
		#  b = Rind::Html::Br.new()
		#  b.expanded_name => 'br'
		#  cn = Custom::Node.new()
		#  cn.expanded_name => 'custom:node'
		def expanded_name
			if @namespace_name == 'rind'
				@local_name
			else
				[@namespace_name, @local_name].join(':')
			end
		end

		# Renders the node in place. This will recursively call
		# <tt>render!</tt> on all child nodes.
		def render!
			@children.render! if not @children.empty?
			self
		end

		def to_s
			attrs = @attributes.collect{|k,v| "#{k}=\"#{v}\""}.join(' ')
			attrs = " #{attrs}" if not attrs.empty?

			if @children.empty?
				"<#{self.expanded_name}#{attrs} />"
			else
				"<#{self.expanded_name}#{attrs}>#{@children}</#{self.expanded_name}>"
			end
		end
	end

	# All of the Array functions have been modified to work with Children.
	# Functions like <tt>pop</tt> that remove a node and return it will
	# remove the association to the parent node. Functions like "push"
	# will automatically associate the nodes to the parent.
	class Children < Nodes
		include Enumerable
		include Equality

		def initialize(parent, *nodes)
			super(nodes)
			@parent = parent
			fix_children!
		end

		def fix_children!
			compact!
			collect! do |node|
				node = Rind::Text.new(node) if node.is_a?(String)
				node.parent = @parent
				node
			end
		end
		private :fix_children!

		def self.call_and_fix_children(*functions)
			functions.each do |f|
				define_method(f) do
					value = super
					fix_children!
					value
				end
			end
		end
		private_class_method :call_and_fix_children
		call_and_fix_children :fill, :insert, :push, :replace, :unshift

		def self.pass_and_clear_parent(*functions)
			functions.each do |f|
				define_method(f) do
					node = super
					node.parent = nil if not node.nil?
					node
				end
			end
		end
		private_class_method :pass_and_clear_parent
		pass_and_clear_parent :delete_at, :pop, :shift

		def delete(child, &block) # :nodoc:
			child = Rind::Text.new(child) if child.is_a?(String)
			node = super(child, &block)
			node.parent = nil if node.respond_to? :parent
			node
		end

		# Replace the child nodes with their rendered values.
		def render!
			nodes = collect{|child| child.respond_to?(:render!) ? child.render! : child}.flatten
			replace(nodes)
		end
	end

	class Text < String
		include Node
	end
end
