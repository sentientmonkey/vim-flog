Vim Flog Plugin
===============

_(Forked from [Ruby Cyclomatic Complexity Plugin](https://github.com/skammer/vim-ruby-complexity) created by @skammer)_

Indicates the Flog number in front of the action in your Ruby code to indicate the complexity.

![Screen shot](http://10to1.blog.s3.amazonaws.com/vim-flog.png)

Requirements
------------

* ruby
* flog rubygem
* vim 7.3+, compiled with:
  * +ruby
  * +signs

Installation
------------

First of all make sure you have a Vim installed with Ruby support. If you use MacVim than you can build your own version of Vim like [this](https://github.com/b4winckler/macvim/wiki/Building).

Here is an example of my configuration during the build:

`./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --enable-cscope`

Install the Flog gem like this: `gem install flog`.

To install the plugin just run this command in your Terminal:

`curl https://raw.github.com/fousa/vim-flog/master/plugin/flog.vim -o ~/.vim/plugin/flog.vim`

When this is done add `:silent exe "g:flog_enable"` to your .vimrc file.

Configuration
-------------

You can set the colors for the complexity indication with the following commands in your .vimrc:

* Set the color of for low complexity: <br/>
    `:let g:flog_low_color_hl = "term=standout ctermfg=118 ctermbg=235 guifg=#999999 guibg=#323232"`

* Set the color of for medium complexity: <br/>
    `:let g:flog_medium_color_hl = "term=standout ctermfg=81 ctermbg=235 guifg=#66D9EF guibg=#323232"`

* Set the color of for high complexity: <br/>
    `:let g:flog_high_color_hl = "term=standout cterm=bold ctermfg=199 ctermbg=16 gui=bold guifg=#F92672 guibg=#232526"`

* Set the background color: <br/>
    `:let s:background_hl    = "guifg=#999999 guibg=#323232 gui=NONE"`

You can set the limits for the complexity indication with the following commands in your .vimrc:

* Set the limit to switch to a medium complexity: <br/>
    `:silent exe "let g:flog_medium_limit=10"`

* Set the limit to switch to a high complexity: <br/>
    :silent exe "`let g:flog_high_limit=20"`

You can hide some levels of complexity:

* Hide low complexity: <br/>
    `:silent exe "let g:flog_hide_low=1"`

* Hide medium complexity: <br/>
    `:silent exe "let g:flog_hide_medium=1"`

You can also turn flog off and on:

* Turn on flog
    `:call EnableFlog()`

* Turn off flog
    `:call DisableFlog()`

* Toggle flog
    `:call ToggleFlog()`

Additionally, you can map this in your .vimrc:
    `:map ,f :call ToggleFlog()<cr>`

Credits
-------

@garybernhardt's [pycomplexity.vim](http://bitbucket.org/garybernhardt/pycomplexity).

@topfunky's [rubycomplexity.el](https://github.com/topfunky/emacs-starter-kit/tree/master/vendor/ruby-complexity/)

@skammer's [Ruby Cyclomatic Complexity Plugin](https://github.com/skammer/vim-ruby-complexity)
