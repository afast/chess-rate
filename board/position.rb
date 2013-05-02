module Board
  class Position
    attr_reader :file, :rank
    FILES = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

    FILE_TO_INT = {
      'a' => 1,
      'b' => 2,
      'c' => 3,
      'd' => 4,
      'e' => 5,
      'f' => 6,
      'g' => 7,
      'h' => 8
    }

    def initialize(file, rank)
      #puts "initializing position file >#{file}< rank >#{rank}<"
      @file = file.downcase if file
      @rank = rank.to_i if rank
    end

    def self.from_algebraic_notation str
      if str.size == 2
        Position.new str[0], str[1]
      elsif str.size == 1
        if FILES.include? str
          Position.new str, nil
        else
          Position.new nil, str.to_i
        end
      else
        Position.new nil, nil
      end
    end

    def valid?
      !@file.nil? && !@rank.nil?
    end

    def valid_rank?
      @rank && (1..8).include?(@rank)
    end

    def valid_file?
      @file && FILES.include?(@file)
    end

    def to_s
      "#{@file}#{@rank}"
    end

    def rank_movement?(position)
      on_rank? position.rank
    end

    def file_movement?(position)
      on_file? position.file
    end

    def diagonal_movement?(position)
      (position.file_to_i - file_to_i).abs  == (position.rank - @rank).abs
    end

    def on_rank?(rank)
      @rank == rank
    end

    def on_file?(file)
      @file == file.downcase
    end

    def file_distance(position)
      (file_to_i - position.file_to_i).abs
    end

    def rank_distance(position)
      (@rank - position.rank).abs
    end

    def file_to_i
      FILE_TO_INT[@file]
    end

    def self.file_to_i file
      FILE_TO_INT[file]
    end

    def file_increment?(position)
      if file_to_i <= position.file_to_i
        1
      else
        -1
      end
    end

    def rank_increment?(position)
      if @rank <= position.rank
        1
      else
        -1
      end
    end
  end
end
