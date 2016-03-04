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
let s:hide_low         = 0
let s:hide_medium      = 0

if exists("g:flog_hide_low")
  let s:hide_low = g:flog_hide_low
endif

if exists("g:flog_hide_medium")
  let s:hide_medium = g:flog_hide_medium
endif

if exists("g:flog_medium_limit")
  let s:medium_limit = g:flog_medium_limit
endif

if exists("g:flog_high_limit")
  let s:high_limit = g:flog_high_limit
endif

ruby << EOF
begin
  require 'rubygems'
  require 'flog'
  FLOG_LOADED = true
rescue LoadError
  FLOG_LOADED = false
end

class Flog
  def return_report
    complexity_results = {}
    each_by_score(threshold) do |class_method, score, call_list|
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
  medium_limit = VIM::evaluate('s:medium_limit')
  high_limit   = VIM::evaluate('s:high_limit')
  hide_medium  = VIM::evaluate('s:hide_medium')
  hide_low     = VIM::evaluate('s:hide_low')

  VIM.command ":silent sign unplace * file=#{VIM::Buffer.current.name}"
  VIM.command ":sign define FlogDummySign"
  VIM.command ":sign place 9999 line=1 name=FlogDummySign file=#{VIM::Buffer.current.name}"

  results.each do |line_number, (score, method)|
    complexity = case score
      when 0..medium_limit          then "LowComplexity"
      when medium_limit..high_limit then "MediumComplexity"
      else                               "HighComplexity"
    end
    value = score >= 100 ? 99 : score.round
    value = nil if (hide_low == 1 && value < medium_limit) || (hide_medium == 1 && value < high_limit)
    if value
      VIM.command ":sign define #{value} text=#{value} texthl=Sign#{complexity}"
      VIM.command ":sign place #{line_number} line=#{line_number} name=#{value} file=#{VIM::Buffer.current.name}"
    end
  end
end
EOF

function! ShowComplexity()
ruby << EOF
  ignore_files = /_spec/

  options = {
    :quiet    => true,
    :all      => true
  }

  if !Vim::Buffer.current.name.match(ignore_files) && FLOG_LOADED
    buffer = ::VIM::Buffer.current
    # nasty hack, but there is no read all...
    code = (1..buffer.count).map{|i| buffer[i]}.join("\n")

    flogger = Flog.new options
    flogger.flog_ruby `cat #{::VIM::Buffer.current.name}`
    flogger.calculate_total_scores
    show_complexity flogger.return_report
  end
EOF
endfunction

function! HideComplexity()
ruby << EOF
  if FLOG_LOADED
    VIM.command ":redir @a"
    VIM.command ":silent sign place file=#{VIM::Buffer.current.name}"
    VIM.command ":redir END"
    placed_signs = VIM.evaluate "@a"
    placed_signs.lines.map(&:chomp).select{|s| s.include? 'id='}.each do |sign|
      id = Hash[*sign.split(' ').map{|s| s.split('=')}.flatten]['id']
      VIM.command ":sign unplace #{id} file=#{VIM::Buffer.current.name}"
    end
  end
EOF
endfunction

function! FlogDisable()
  let g:flog_enable = 0
  call HideComplexity()
endfunction
command! FlogDisable call FlogDisable()

function! FlogEnable()
  let g:flog_enable = 1
  call ShowComplexity()
endfunction
command! FlogEnable call FlogEnable()

function! FlogToggle()
  if exists("g:flog_enable") && g:flog_enable
    call FlogDisable()
  else
    call FlogEnable()
  endif
endfunction
command! FlogToggle call FlogToggle()

if !exists("g:flog_enable") || g:flog_enable
  au BufReadPost,BufWritePost,FileReadPost,FileWritePost *.rb call ShowComplexity()
endif
