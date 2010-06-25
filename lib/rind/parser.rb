module Rind
	TEXT      = 0
	CDATA     = 1
	COMMENT   = 2
	DOCTYPE   = 3
	PRO_INST  = 4
	END_TAG   = 5
	START_TAG = 6

	def self.parse(file_name, type, base_namespace, namespaces_allowed)
		create_tree(tokenize(file_name, type), type, base_namespace, namespaces_allowed)
	end

	def self.tokenize(file_name, type)
		content = File.read(file_name)

		# tag types
		cdata = /<!\[CDATA\[(.*?)\]\]>/m
		comment = /<!--(.*?)-->/m
		doctype = /<!DOCTYPE(.*?)>/m
		processing_instruction = /<\?(.*?)>/m
		full_tag = /<\s*(script|style)\s*(.*?)>(.*?)<\s*\/\s*\5\s*>/m
		end_tag = /<\s*\/\s*((?:\w+:)?\w+)\s*>/m
		start_tag = /<\s*((?:\w+:)?\w+)\s*(.*?)\/?\s*>/m

		if type == 'html'
			scan_regex = /#{cdata}|#{comment}|#{doctype}|#{processing_instruction}|#{full_tag}|#{end_tag}|#{start_tag}/o
		else # xml
			scan_regex = /#{cdata}|#{comment}|#{doctype}|#{processing_instruction}|#{end_tag}|#{start_tag}/o
		end

		# extract tokens from the file content
		tokens = Array.new
		text_start = 0
		content.scan(scan_regex) do |token|
			# remove nil entries from the unmatched tag checks
			token.compact!
			# get match object
			match = $~

			# create a proceeding text token if one exists
			text_end = match.begin(0)
			if text_start < text_end
				text = content[text_start...text_end]
				tokens.push([TEXT, text]) if text !~ /\A\s*\z/
			end
			text_start = match.end(0)

			# create a token for the appropriate tag
			if match.begin(1)
				tokens.push([CDATA, token].flatten)
			elsif match.begin(2)
				tokens.push([COMMENT, token].flatten)
			elsif match.begin(3)
				tokens.push([DOCTYPE, token].flatten)
			elsif match.begin(4)
				tokens.push([PRO_INST, token].flatten)
			# from here things vary a little
			#
			# html => full tag = 5, end tag = 8, start tag = 9
			# xml => end tag = 5, start tag = 6
			elsif match.begin(5)
				if type == 'html'
					if token[2].nil?
						attr = nil
						text = token[1]
					else
						attr = token[1]
						text = token[2]
					end
					tokens.push([START_TAG, token[0], attr])
					if text.sub!(/\A\s*#{comment}\s*\z/o, '\1')
						tokens.push([COMMENT, text])
					elsif text !~ /\A\s*\z/
						tokens.push([TEXT, text])
					end
					tokens.push([END_TAG, token[0]])
				else
					tokens.push([END_TAG, token].flatten)
				end
			elsif match.begin(6)
				tokens.push([START_TAG, token].flatten)
			elsif match.begin(8)
				tokens.push([END_TAG, token].flatten)
			elsif match.begin(9)
				tokens.push([START_TAG, token].flatten)
			end
		end

		tokens
	end
	private_class_method :tokenize

	# tokens will arrive in reverse order
	def self.create_tree(tokens, type, base_namespace, namespaces_allowed, complete_tag = nil)
		dom = Rind::Nodes[]

		# create the nodes and push them onto the dom tree
		while 0 < tokens.length
			token = tokens.pop

			case token[0]
			when TEXT
				dom.push(Rind::Text.new(token[1]))
			when CDATA
				dom.push(Rind::CDATA.new(token[1]))
			when COMMENT
				dom.push(Rind::Comment.new(token[1]))
			when DOCTYPE
				dom.push(Rind::DocType.new(token[1]))
			when PRO_INST
				dom.push(Rind::ProcessingInstruction.new(token[1]))
			when END_TAG
				# recursively retreive all the children and the matching start tag
				children = create_tree(tokens, type, base_namespace, namespaces_allowed, token[1])
				start_tag = children.shift

				start_tag.children.replace(children)

				dom.push(start_tag)
			when START_TAG
				namespace_name, local_name = extract_name_and_namespace(token[1], base_namespace)

				# create the element
				if not namespaces_allowed.nil? and (namespace_name == base_namespace or namespaces_allowed.include? namespace_name)
					passed_namespace = namespace_name == base_namespace ? nil : namespace_name
					begin
						node = create_node(get_library_name(namespace_name), local_name.capitalize, token[2], nil, passed_namespace)
					rescue
						node = create_node("Rind::#{type.capitalize}", local_name.capitalize, token[2], nil, passed_namespace)
					end
				else
					node = create_node("Rind::#{type.capitalize}", local_name.capitalize, token[2], nil, namespace_name)
				end
				dom.push(node)

				# break if this tag completes the grouping from an end tag
				break if complete_tag.eql?(token[1])
			end
		end

		# output in the correct order
		dom.reverse
	end
	private_class_method :create_tree

	def self.extract_name_and_namespace(tag_name, base_namespace)
		tag_name =~ /^(?:([\w:]+):)?(\w+)$/
		namespace_name, local_name = $1, $2
		namespace_name = base_namespace if namespace_name.nil?

		[namespace_name, local_name]
	end
	private_class_method :extract_name_and_namespace

	def self.get_library_name(namespace_name)
		namespace_name.split(/:/).collect{|ns| ns.capitalize}.join('::')
	end
	private_class_method :get_library_name

	def self.create_node(class_namespace, class_name, attributes, children, namespace_name)
		command = "#{class_namespace}::#{class_name.capitalize}.new("
		options = [":attributes => attributes"]
		options.push(":namespace_name => '#{namespace_name}'")
		options.push(":children => children") if not children.nil?
		command.concat(options.join(','))
		command.concat(')')

		class_eval(command)
	end
	private_class_method :create_node
end
