class SimpleParser
  def parse(pgn_file_id, path)
    reading_tags = false
    reading_pgns = false
    read_pgns = false
    game_read = false
    pgn = ''

    games = []
    g = Game.new
    g.pgn_file_id = pgn_file_id

    IO.foreach(path) do |line|
      line.strip!
      if line =~ /^\[/
        game_read = false
        g.set_tag(line.scan(/^\[([^ ]+)/).first.first, line.scan(/("[^"]+[^\]]+)\]/).first.first)
        if read_pgns
          raise "Unexpected tag start"
        else
          reading_tags = true
        end
      elsif line.nil? || line == ""
        if reading_tags
          read_pgns = true
        elsif game_read
          game_read # puts 'Waiting for next game'
        else
          game_read = true
          unless read_pgns

            # clean up
            pgn.gsub!(/\([^\)]*\)/, ' ')
            pgn.gsub!(/{[^}]*}/, ' ')
            pgn.gsub!(/\$[\d]+/, ' ')
            pgn.gsub!(/\s+/, ' ')

            # create game
            assign_moves(g, pgn.split(/\d+\.+/).map { |a| a.strip.split(' ') }.flatten)
            g.save
            g = nil
            g = Game.new
            g.pgn_file_id = pgn_file_id
            pgn = nil
            pgn = ''
          end
        end
        reading_tags = false
        reading_pgns = false
      else
        read_pgns = false
        reading_pgns = true
        pgn += ' ' + line.gsub('\n', ' ').gsub('\r', ' ').gsub(/\s+/, ' ')
      end
      raise "Game read error" if game_read && reading_pgns && reading_tags && read_pgns
    end
  end

  private
  def assign_moves(game, moves)
    white_move = true
    move_number = 1
    moves.each do |m|
      move = Move.new
      if ['*', '0-1', '1-0', '1/2-1/2'].include?(m)
        game.result = m
      else
        move.side = white_move
        move.number = move_number
        if white_move
          white_move = false
        else
          white_move = true
          move_number += 1
        end
        case m[-1]
        when '+'
          move.set_check
          move.pgn = m[0..-2]
        when '#'
          move.set_checkmate
          move.pgn = m[0..-2]
        else
          move.pgn = m
        end
        game.add_move move
      end
    end
    game.save_moves
  end
end
