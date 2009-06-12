require 'rdoc/ri/ri_driver'

# class RiDriver
#   def initialize(args = ARGV.dup)
#     @options = RI::Options.instance
# 
#     if ENV["RI"]
#       args = ENV["RI"].split.concat(args)
#     end
# 
#     @options.parse(args)
# 
#     path = @options.path
#     report_missing_documentation @options.raw_path if path.empty?
# 
#     @ri_reader = RI::RiReader.new(RI::RiCache.new(path))
#     @display   = @options.displayer
#   end
# end

# RI_ARGS = %w(-f ansi)

# def ri(*args)
#   args = RI_ARGS + args.map {|arg| arg.to_s}
#   RiDriver.new(args).process_args
# end

require 'irb/completion'
require 'irb/ext/save-history'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

def time(&block)
  require 'benchmark'
  result = nil
  timing = Benchmark.measure do
    result = block.call()
  end
  puts "It took: #{timing}"
  result
end
