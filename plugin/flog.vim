" File:        flog.vim
" Description: Ruby cyclomatic complexity analizer
" Author:      Max Vasiliev <vim@skammer.name>
" Author:      Jelle Vandebeeck <jelle@fousa.be>
" Licence:     WTFPL
" Version:     0.0.2

if !has('signs') || !has('ruby')
  finish
endif

let s:low_color        = "#a5c261"
let s:medium_color     = "#ffc66d"
let s:high_color       = "#cc7833"
let s:background_color = "#323232"
let s:medium_limit     = 10
let s:high_limit       = 20

if exists("g:flog_low_color")
  let s:low_color = g:flog_low_color
endif

if exists("g:flog_medium_color")
  let s:medium_color = g:flog_medium_color
endif

if exists("g:flog_high_color")
  let s:high_color = g:flog_high_color
endif

if exists("g:flog_background_color")
  let s:background_color = g:flog_background_color
endif

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
  def in_method(name, file, line, endline=nil)
    endline = line if endline.nil?
    method_name = Regexp === name ? name.inspect : name.to_s
    @method_stack.unshift method_name
    @method_locations[signature] = "#{file}:#{line}:#{endline}"
    yield
    @method_stack.shift
  end

  def process_defn(exp)
    in_method exp.shift, exp.file, exp.line, exp.last.line do
      process_until_empty exp
    end
    s()
  end

  def process_defs(exp)
    recv = process exp.shift
    in_method "::#{exp.shift}", exp.file, exp.line, exp.last.line do
      process_until_empty exp
    end
    s()
  end

  def process_iter(exp)
    context = (self.context - [:class, :module, :scope])
    context = context.uniq.sort_by { |s| s.to_s }

    if context == [:block, :iter] or context == [:iter] then
      recv = exp.first

      # DSL w/ names. eg task :name do ... end
      if (recv[0] == :call and recv[1] == nil and recv.arglist[1] and
          [:lit, :str].include? recv.arglist[1][0]) then
          msg = recv[2]
          submsg = recv.arglist[1][1]
          in_klass msg do
            lastline = exp.last.respond_to?(:line) ? exp.last.line : nil # zomg teh hax!
            # This is really weird. If a block has nothing in it, then for some
            # strange reason exp.last becomes nil. I really don't care why this
            # happens, just an annoying fact.
            in_method submsg, exp.file, exp.line, lastline do
              process_until_empty exp
            end
          end
          return s()
      end
    end
    add_to_score :branch
    exp.delete 0
    process exp.shift
    penalize_by 0.1 do
      process_until_empty exp
    end
    s()
  end

  def return_report
    complexity_results = {}
    max = option[:all] ? nil : total * THRESHOLD
    each_by_score max do |class_method, score, call_list|
      location = @method_locations[class_method]
      if location then
        line, endline = location.match(/.+:(\d+):(\d+)/).to_a[1..2].map{|l| l.to_i }
        # This is a strange case of flog failing on blocks.
        # http://blog.zenspider.com/2009/04/parsetree-eol.html
        line, endline = endline-1, line if line >= endline
        complexity_results[line] = [score, class_method, endline]
      end
    end
    complexity_results
  ensure
    self.reset
  end
end

def show_complexity(results = {})
  VIM.command ":silent sign unplace file=#{VIM::Buffer.current.name}"
  results.each do |line_number, rest|
    medium_limit = VIM::evaluate('s:medium_limit')
    high_limit = VIM::evaluate('s:high_limit')
    complexity = case rest[0]
      when 0..medium_limit          then "low_complexity"
      when medium_limit..high_limit then "medium_complexity"
      else                               "high_complexity"
    end
		value = rest[0].to_i
		value = "9+" if value >= 100
		VIM.command ":sign define #{value.to_s} text=#{value.to_s} texthl=#{complexity}"
    VIM.command ":sign place #{line_number} line=#{line_number} name=#{value.to_s} file=#{VIM::Buffer.current.name}"
  end
end

EOF

function! s:UpdateHighlighting()
  exe 'hi low_complexity    guifg='.s:low_color
  exe 'hi medium_complexity guifg='.s:medium_color
  exe 'hi high_complexity   guifg='.s:high_color
	exe 'hi SignColumn        guifg=#999999 guibg='.s:background_color.' gui=NONE'
endfunction

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

call s:UpdateHighlighting()

endfunction

call s:UpdateHighlighting()

sign define low_color    text=XX texthl=low_complexity
sign define medium_color text=XX texthl=medium_complexity
sign define high_color   text=XX texthl=high_complexity


if !exists("g:flow_enable") || g:flog_enable
  autocmd! BufReadPost,BufWritePost,FileReadPost,FileWritePost *.rb call ShowComplexity()
endif
