class Move < ActiveRecord::Base
  attr_accessible :annotator_move, :annotator_value, :check, :comments, :lan, :mate, :number, :pgn, :player_value, :side, :game

  serialize :comments, Array

  belongs_to :game

  scope :black, where(side: false)
  scope :white, where(side: true)

  # A valuation should be a comment with {Annotator: move_value / annotator_value
  def add_comment comment
    comments << comment

    # match values and assign (if two are present assume first for player move and
    # second for annotator's best calculation
    values = comment.scan(/[+-][0-9]+\.[0-9]+/)
    if values.size > 0
      player_value = values[0].to_f
      annotator_value = (values[1] ? values[1] : values[0]).to_f
    end
    # match lan move suggested by the engine
    engine_moves = comment.scan(/[a-h][1-8][a-h][1-8]/)
    if engine_moves.size > 0
      annotator_move = engine_moves[0]
    end
  end

  def side_sym
    self.side ? :white : :black
  end

  def set_check
    check = true
  end

  def set_checkmate
    check = true
    mate = true
    # These values are usually absent from comments
    # The deviation is clearly 0 for a checkmate
    annotator_value = (white? ? 1 : -1)*327.4
    player_value = annotator_value
  end

  def to_s
    # Show basic move info
    #"#{(index+2)/2}#{sideNotation}#{lan_move} {#{board_score},#{machine_move},#{machine_score},#{(machine_score-board_score).abs}}"
    "#{number}#{side_to_s}#{pgn} { #{player_value}#{machine_info} }"
  end

  def machine_info
    if deviation && deviation > 0
      " / #{annotator_move}  #{annotator_value}, #{deviation_to_s}"
    end
  end

  def blunder?(tie_threshold=1, blunder_threshold=3)
    return false unless annotator_value && player_value
    deviation > blunder_threshold &&
      (annotator_value > tie_threshold && player_value < tie_threshold ||
      annotator_value > -tie_threshold && player_value < -tie_threshold)
  end

  def side_to_s
    white? ? '.' : '...'
  end

  def deviation_to_s
    self.deviation ? '%.2f' % self.deviation : ''
  end

  def standard_deviation(avg)
    (deviation - avg) ** 2
  end

  def deviation # Calculate deviation for this move
    # SCIDvsPC using Houdini returns the advantage calculation for whites
    # So a greater number is better for white and a lower number is better
    # for black. With 0 being the balance
    return player_value || 0 unless annotator_value
    case
    when white? then annotator_value - player_value
    when black? then player_value - annotator_value
    else nil
    end
  end

  def set_side text
    # SCIDvsPC using Houdini leave '.' for white
    # and '...' (move continuation) for black
    self.side = case text
            when '.' then true
            when '...' then false
            end
  end

  def black?
    self.side_sym == :black
  end

  def white?
    self.side_sym == :white
  end
end
