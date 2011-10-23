require 'tempfile'

def run_program program
  source = Tempfile.new ['program', '.challenge']
  source.puts program
  source.flush

  base = source.path.sub(/.challenge$/, '')
  interpreter = "#{File.dirname __FILE__}/../interpreter"
  `#{interpreter} #{source.path} > #{base}.stdout 2> #{base}.stderr`

  result = {:exit_status => $?.exitstatus}
  result[:stdout] = File.read "#{base}.stdout"
  result[:stderr] = File.read "#{base}.stderr"

  File.delete "#{base}.stdout"
  File.delete "#{base}.stderr"
  source.close

  result
end
