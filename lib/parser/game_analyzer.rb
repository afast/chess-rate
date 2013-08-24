class GameAnalyzer

  def initialize(games, time, tie_threshold, blunder_threshold, db_ref)
    @games = games
    @motor_path = MOTOR_PATH
    @db_ref = db_ref
    @time = time || 100
    @tie_threshold = tie_threshold || 1.56
    @blunder_threshold = blunder_threshold || 2
  end

  def analyze_games
    @uci = Uci.new(:engine_path => @motor_path, movetime: @time, debug: false)

    @uci.wait_for_readyok
    board = Board::Board.new

    @games.each do |game|
      if game.moves.empty?
        game.destroy
        next
      end
      game.update_attributes! tie_threshold: @tie_threshold, blunder_threshold: @blunder_threshold
      game.reset_statistics!

      board.setup_board # Reset our custom board
      @uci.new_game!
      @uci.wait_for_readyok

      # Set game properties
      board_score = 0

      old_move = game.moves.first
      old_lan_move = old_bestmove = old_score = nil
      move_count = game.moves.size

      first_time_here = true

      @uci.send_position_to_engine

      # Analyze each move of the game
      game.moves.each_with_index do |move, index|
        # Get the LAN move from our custom board
        lan_move = board.move move.pgn, move.side_sym
        move.lan = lan_move
        old_lan_move = lan_move if old_lan_move.nil? # The first time old_lan_move has lan_move

        game.update_attributes! progress: (index+1)/move_count.to_f
        # Ask our engine for the current score and best move
        score, best_move = @uci.analyse_position

        # Correct score
        if score.nil? # Assume the score did not change
          score = old_score
        else
          score *= -1 if move.black? # Change to white's perspective
        end

        # initialize first score
        old_score = score if old_score.nil?

        # Stabilize score, bestmove results
        if old_lan_move == old_bestmove
          # The newest score is more reliable if the player matched the best move
          old_score = score
        elsif score > old_score && old_move.white? || score < old_score && old_move.black?
          # If the new evaluation says that the user's move has a better score, it is the better move
          old_bestmove = old_lan_move
          old_score = score
        end

        if index > 0 # Start assigning after first move was scored
          old_move.update_attributes! player_value: score, annotator_value: old_score, annotator_move: old_bestmove

          if @db_ref
            percentage, coincidences = @db_ref.getPercentage(@uci.fenstring)

            if coincidences == 0 && first_time_here
              player = nil
              if old_move.side.eql? 'white'
                player = Player.where(id: game.white).first
              else
                player = Player.where(id: game.black).first
              end
              game.update_attributes! player_out_db_ref: player.name, move_out_db_ref: (index+1)/2, value_out_db_ref: score,
                                      best_value_out_db_ref: old_score, deviation_out_db_ref: (score-old_score).abs
              first_time_here = false
            elsif coincidences > 0
              first_time_here = true
            end
          end
        end

        old_score = score
        old_move = move
        old_lan_move = lan_move
        old_bestmove = best_move

        # Send position to engine
        @uci.move_piece lan_move
        @uci.send_position_to_engine

        if move_count == index - 1 # update last move
          old_move.update_attributes! player_value: old_score, annotator_value: old_score, annotator_move: old_bestmove
        end
      end
      game.set_statistics!

    end
    @uci.close_engine_connection
  end
end
