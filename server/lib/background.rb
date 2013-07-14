module Background
  def background(&block)
    Spawnling.new do
      begin
        yield
      rescue
        puts $!.message
        puts $!.backtrace
        File.open('log/thread_exception.log', 'w') do |f|
          f.puts $!.message
          f.puts $!.backtrace
        end
      end
    end
  end
end
