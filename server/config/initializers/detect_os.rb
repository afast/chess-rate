require 'rbconfig'
case RbConfig::CONFIG['host_os']
when /mswin|windows/i
  OS = :windows
  prefix = ''
when /linux/i
  OS = :linux
  prefix = 'wine '
when /darwin/i
  OS = :osx
  prefix = ''
else
  OS = :unknown
  prefix = ''
end
case RbConfig::CONFIG['host_cpu']
when /64/i
  ARCH_64 = true
  arch = 'x64'
else
  ARCH_64 = false
  arch = 'w32'
end

MOTOR_PATH = "#{prefix}#{File.join(Rails.root, 'bin', "Houdini_15a_#{arch}.exe")}"
PGN_TO_FEN = "#{prefix}#{File.join(Rails.root, 'bin', "pgn2fen.exe")}"
