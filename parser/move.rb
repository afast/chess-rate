class Move
  attr_accessor :side, :move, :player_value, :annotator_value, :number, :comments, :check, :mate

  def initialize
    @comments = []
  end

  # A valuation should be a comment with {Annotator: move_value / annotator_value
  def add_comment comment
    comments << comment

    # match values and assign (if two are present assume first for player move and
    # second for annotator's best calculation
    values = comment.scan(/[+-][0-9]+\.[0-9]+/)
    if values.size > 0
      @player_value = values[0].to_f
      @annotator_value = (values[1] ? values[1] : values[0]).to_f
    end
  end

  def set_check
    @check = true
  end

  def set_checkmate
    @check = true
    @mate = true
    # These values are usually absent from comments
    # The deviation is clearly 0 for a checkmate
    @annotator_value = 0
    @player_value = 0
  end

  def to_s
    # Show basic move info
    "#{number}. #{move} - deviation: #{'%.2f' % self.deviation}"
  end

  def deviation # Calculate deviation for this move
    # SCIDvsPC using Houdini returns the advantage calculation for whites
    # So a greater number is better for white and a lower number is better
    # for black. With 0 being the balance
    return 'Values not set' unless @annotator_value && @player_value
    case @side
    when :white then @annotator_value - @player_value
    when :black then @player_value - @annotator_value
    else 'No side set'
    end
  end

  def set_side text
    # SCIDvsPC using Houdini leave '.' for white
    # and '...' (move continuation) for black
    @side = case text
            when '.' then :white
            when '...' then :black
            else :unknown
            end
  end

  def black?
    @side == :black
  end

  def white?
    @side == :white
  end
end
