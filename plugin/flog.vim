" File:        flog.vim
" Description: Ruby cyclomatic complexity analizer
" Author:      Max Vasiliev <vim@skammer.name>
" Author:      Jelle Vandebeeck <jelle@fousa.be>
" Licence:     WTFPL
" Version:     0.0.2

if !has('signs') || !has('ruby')
  finish
endif

let s:medium_limit     = 10
let s:high_limit       = 20

if exists("g:flog_medium_limit")
  let s:medium_limit = g:flog_medium_limit
endif

if exists("g:flog_high_limit")
  let s:high_limit = g:flog_high_limit
endif

ruby << EOF

require 'rubygems'
require 'flog'

class Flog
  def return_report
    complexity_results = {}
    max = option[:all] ? nil : total * THRESHOLD
    each_by_score max do |class_method, score, call_list|
      location = @method_locations[class_method]
      if location then
        line = location.match(/.+:(\d+)/).to_a[1]
        complexity_results[line] = [score, class_method]
      end
    end
    complexity_results
  ensure
    self.reset
  end
end

def show_complexity(results = {})
  VIM.command ":silent sign unplace file=#{VIM::Buffer.current.name}"
  medium_limit = VIM::evaluate('s:medium_limit')
  high_limit = VIM::evaluate('s:high_limit')

  results.each do |line_number, (score, method)|
    complexity = case score
      when 0..medium_limit          then "LowComplexity"
      when medium_limit..high_limit then "MediumComplexity"
      else                               "HighComplexity"
    end
		value = score.to_i
		value = "9+" if value >= 99
		VIM.command ":sign define l#{value.to_s} text=#{value.to_s} texthl=Sign#{complexity}"
    VIM.command ":sign place #{line_number} line=#{line_number} name=l#{value.to_s} file=#{VIM::Buffer.current.name}"
  end
end

EOF

function! ShowComplexity()
ruby << EOF
  options = {
    :quiet    => true,
    :continue => true,
    :all      => true
  }

  flogger = Flog.new options
  flogger.flog ::VIM::Buffer.current.name
  show_complexity flogger.return_report
EOF
endfunction

if !exists("g:flow_enable") || g:flog_enable
  au bufnewfile,bufread *.rb call ShowComplexity()
endif
