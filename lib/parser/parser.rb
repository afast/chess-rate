require 'node_extensions'
class Parser
  base_path = File.expand_path(File.dirname(__FILE__))

  # Load the Treetop grammar from the 'pgn_parser' file, and
  # create a new instance of that parser as a class variable
  # so we don't have to re-create it every time we need to
  # parse
  Treetop.load(File.join(base_path, 'pgn_parser.treetop'))
  @@parser = PGNParser.new

  def self.parse(data)
    # Pass the data over to the parser instance
    tree = @@parser.parse(data)

    # If the AST is nil then there was an error during parsing
    # we need to report a simple error message to help the user
    if(tree.nil?)
      from = @@parser.index-1
      puts data[@@parser.index] # Character with problem
      puts ">#{data[@@parser.index, 3]}<" # three characters of context
      from = @@parser.index-10
      from = 0 if from < 0
      puts "-->#{data[from, 20]}<--" # 20 characters of context
      from = @@parser.index-20
      from = 0 if from < 0
      puts "-->#{data[from, 40]}<--" # 20 characters of context
      from = @@parser.index-40
      from = 0 if from < 0
      puts "-->#{data[from, 80]}<--" # 20 characters of context
      raise Exception, "Parse error at offset: #{@@parser.index}"
    end

    clean_tree tree # Clean up all nodes that we did not specifically match

    return tree
  end

  private
  def self.clean_tree(root_node)
    return if(root_node.elements.nil?)
    root_node.elements.delete_if{|node| node.class.name == "Treetop::Runtime::SyntaxNode" }
    root_node.elements.each {|node| self.clean_tree(node) }
  end
end
