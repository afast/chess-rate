class PGN_Analyzer

  def initialize(file_path)
    originalPath = String.new(file_path)
    originalPath.slice! ".txt"
    @game_number_path = originalPath + "_GameNumber.txt"
    @bd_ref_path = originalPath + "_BD-REF.txt"
    @pgn_path = originalPath + ".pgn"
    @file_path = file_path
  end

  def count_coincidences(to_analyze)
    inFile = File.open(@file_path,"r")
    coincidences = 0
    inFile.each do |line|
      if line.start_with? to_analyze
        coincidences += 1
      end
    end
    inFile.close
    coincidences
  end

  def add_game_number
    inFile = File.open(@file_path,"r")
    outFile = File.open(@game_number_path,"w")
    gameNumber = 0
    inFile.each do |line|
      fenArray = line.split(' ')
      if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
        gameNumber += 1
      end
      newLine = line.chop + " " + gameNumber.to_s
      outFile.puts(newLine)
    end
    inFile.close
    outFile.close
  end

  def generate_BD_REF
    pgnFile = File.open(@pgn_path,"r")
    fenFile = File.open(@game_number_path,"r")
    finalFile = File.open(@bd_ref_path,"w")

    winner = "d"
    fenFile.each do |fenLine|
      match = fenLine.split(' ').last
      fenArray = fenLine.split(' ')
      if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
        until (pgnLine = pgnFile.readline).start_with? '[Result '; end
        result = pgnLine.split('"')[1]
        if result.eql? '1-0'
          winner = "w"
        elsif result.eql? '0-1'
          winner = "b"
        else
          winner = "d"
        end
      end
      newLine = fenLine.chop + " " + winner
      finalFile.puts(newLine)
    end

    finalFile.close
    fenFile.close
    pgnFile.close
  end

  def getPercentage(bd_path, to_analyze)
    inFile = File.open(bd_path,"r")
    coincidences = 0
    points = 0
    inFile.each do |line|
      if line.start_with? to_analyze
        coincidences += 1
        if line.split(' ').last.eql? 'd'
          points += 0.5
        elsif line.split(' ').last.eql? 'w'
          points += 1
        end
      end
    end
    inFile.close
    if coincidences == 0
      return -1
    end
    points/coincidences*100
  end

  # analyze the file defined by file_path
  def file_analyzer
    # open the file
    inFile = File.open(@file_path,"r")

    # here are defined all regular expressions used next
    event_exp = /\[Event /
    date_exp = /\[Date /
    white_pl_exp = /\[White /
    black_pl_exp = /\[Black /
    white_avg_error_exp = /\[WhiteAvgError /
    white_std_dev_exp = /\[WhiteStdDeviation /
    white_perf_moves_exp = /\[WhitePerfectMoves /
    white_blund_exp = /\[WhiteBlunders /
    black_avg_error_exp = /\[BlackAvgError /
    black_std_dev_exp = /\[BlackStdDeviation /
    black_perf_moves_exp = /\[BlackPerfectMoves /
    black_blund_exp = /\[BlackBlunders /

    white_moves_exp = /\d\.[A-Za-z]/
    black_moves_exp = /\d\.\.\.[A-Za-z]/
    final_result_exp = /\d-\d/

    white_moves = 0
    black_moves = 0

    # for each line in file, check every regular expression
    inFile.each do |line|
      if line.start_with? '['
        if line =~ event_exp
          event = line.split('"')[1]
        end
        if line =~ date_exp
          date = line.split('"')[1]
        end
        if line =~ white_pl_exp
          white_player = line.split('"')[1]
        end
        if line =~ black_pl_exp
          black_player = line.split('"')[1]
        end
        if line =~ white_avg_error_exp
          white_avg_error = line.split(' ')[1].split(']')[0]
        end
        if line =~ white_std_dev_exp
          white_std_dev = line.split(' ')[1].split(']')[0]
        end
        if line =~ white_perf_moves_exp
          white_perf_moves = line.split(' ')[1].split(']')[0]
        end
        if line =~ white_blund_exp
          white_blunders = line.split(' ')[1].split(']')[0]
        end
        if line =~ black_avg_error_exp
          black_avg_error = line.split(' ')[1].split(']')[0]
        end
        if line =~ black_std_dev_exp
          black_std_dev = line.split(' ')[1].split(']')[0]
        end
        if line =~ black_perf_moves_exp
          black_perf_moves = line.split(' ')[1].split(']')[0]
        end
        if line =~ black_blund_exp
          black_blunders = line.split(' ')[1].split(']')[0]
        end
      else
        if line =~ white_moves_exp
          white_moves += 1
        end
        if line =~ black_moves_exp
          black_moves += 1
        end
        if line =~ final_result_exp
          # at this point, we've all the information about the game
          # all variables about players and tournaments should be updated

          #restart the total moves for each player
          white_moves = 0
          black_moves = 0
        end
      end
    end
    inFile.close
  end

end

#analyzer = PGN_Analyzer.new '../pgn/games_analyzed_analyzed.pgn'
analyzer = PGN_Analyzer.new 'D:/Facultad/Proyecto de Grado/pgn2fen/Capablanca.txt'
analyzer.add_game_number
analyzer.generate_BD_REF
puts analyzer.getPercentage 'D:/Facultad/Proyecto de Grado/pgn2fen/Capablanca_BD-REF.txt', 'r1bqkbnr/pppp1ppp/2n5/8/3pP3/5N2/PPP2PPP/RNBQKB1R '