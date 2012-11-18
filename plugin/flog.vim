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
  # MONKEY: endline addition
  def in_method(name, file, line, endline=nil)
    endline = line if endline.nil?
    method_name = Regexp === name ? name.inspect : name.to_s
    @method_stack.unshift method_name
    @method_locations[signature] = "#{file}:#{line}:#{endline}"
    yield
    @method_stack.shift
  end

  # MONKEY: exp.last.line addition
  def process_defn(exp)
    in_method exp.shift, exp.file, exp.line, exp.last.line do
      process_until_empty exp
    end
    s()
  end

  # MONKEY: exp.last.line addition
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
      #   looks like s(:call, nil, :task, s(:lit, :name))
      #           or s(:call, nil, :task, s(:str, "name"))
      #           or s(:call, nil, :task, s(:hash, s(:lit, :name) ...))

      t, r, m, *a = recv

      if t == :call and r == nil and submsg = dsl_name?(a) then
        m = "#{m}(#{submsg})" if m and [String, Symbol].include?(submsg.class)
        in_klass m do                             # :task/namespace
          # MONKEY: addition of lastline passing
          lastline = exp.last.respond_to?(:line) ? exp.last.line : nil
          in_method submsg, exp.file, exp.line, lastline do # :name
            process_until_empty exp
          end
        end
        return s()
      end
    end

    add_to_score :branch

    exp.delete 0 # { || ... } has 0 in arg slot

    process exp.shift # no penalty for LHS

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
  medium_limit = VIM::evaluate('s:medium_limit')
  high_limit = VIM::evaluate('s:high_limit')

  results.each do |line_number, rest|
    complexity = case rest[0]
      when 0..medium_limit          then "LowComplexity"
      when medium_limit..high_limit then "MediumComplexity"
      else                               "HighComplexity"
    end
		value = rest[0].to_i
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
