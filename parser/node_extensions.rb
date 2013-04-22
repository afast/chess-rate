# Classes used while parsing
module PGN
  class GameList < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def get_games
      # Create Game objects, populate values and return them
      self.elements.map { |x| x.get_game }.flatten.compact
    end
  end
  class SpacedGames < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def get_game
      # Create Game objects, populate values and return them
      self.elements.map { |x| x.get_game }
    end
  end
  class SpacedGame < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def get_game
      # Create Game objects, populate values and return them
      self.elements.select{ |el| el.is_a?(GameNode) }.map { |x| x.get_game }
    end
  end
  class GameNode < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def get_game
      g = Game.new # new game
      self.elements.each { |x| x.set_values(g) } #set game values
      g
    end
  end

  class AnnotatedMove < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def set_values(g)
      # Create new move and set its values
      m = Move.new
      self.elements.each { |x| x.set_values(m) }
      g.add_move m
    end
  end

  class MoveSequence < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def set_values(g)
      # set the values for each move
      self.elements.each { |x| x.set_values(g) }
    end
  end

  class TagExpressions < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def set_values(g)
      # Add tags to game
      self.elements.each { |x| x.set_values(g) }
    end
  end

  class TagExpression < Treetop::Runtime::SyntaxNode
    def print
      p self.text_value
      self.elements.each { |x| x.print }
    end

    def set_values(g)
      # Add each tag to the game
      g.set_tag self.get_tag, self.get_value
    end

    def get_tag
      self.elements.select { |x| x.is_a?(TagIdentifier) }.first.text_value
    end

    def get_value
      self.elements.select { |x| x.is_a?(StringLiteral) }.first.text_value
    end
  end

  class StringLiteral < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
  end

  class TagIdentifier < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
  end

  class MoveLiteral < Treetop::Runtime::SyntaxNode
    def print
      p self.text_value
      self.elements.each { |x| x.print }
    end
    def set_values(m)
      # Set the values of each component (moveliteral, comment, variation)
      self.elements.each { |x| x.set_values(m) }
    end
  end

  class MoveType < Treetop::Runtime::SyntaxNode
    def print
    end
    def set_values(m)
      m.move = self.text_value # Store the move string
    end
  end

  class MoveNumber < Treetop::Runtime::SyntaxNode
    def print
    end
    def set_values(m)
      m.number = self.text_value.to_i # Store the move number
    end
  end

  class MoveSide < Treetop::Runtime::SyntaxNode
    def print
    end
    def set_values(m) # Set move side white/black
      m.set_side self.text_value
    end
  end

  class Nags < Treetop::Runtime::SyntaxNode
    # Numeric Annotation Glyphs
    def print; end
    def set_values(m) # store each nag value
      self.elements.each { |x| x.set_values(m) }
    end
  end

  class Nag < Treetop::Runtime::SyntaxNode
    # Numeric Annotation Glyph
    def print; end
    def set_values
      # store valuations
      m.valuations << self.text_value
    end
  end

  class Comment < Treetop::Runtime::SyntaxNode
    def print
      p self.text_value
      self.elements.each { |x| x.print }
    end
    def set_values(m)
      # Store comments to extract valorations from the annotator
      m.add_comment self.text_value
    end
  end

  class Variant < Treetop::Runtime::SyntaxNode
    def print
      self.elements.each { |x| x.print }
    end
    def set_values(m)
      # Store the variant only if we are going to use it
    end
  end

  class Check < Treetop::Runtime::SyntaxNode
    def print
    end
    def set_values(m)
      m.set_check # Set a check move
    end
  end

  class Checkmate < Treetop::Runtime::SyntaxNode
    def print
    end
    def set_values(m)
      m.set_checkmate # Set checkmate move
    end
  end
end

# for convenience to avoid asking the type everywhere
class Treetop::Runtime::SyntaxNode
  def set_values *arguments
  end
  def print
  end
end
