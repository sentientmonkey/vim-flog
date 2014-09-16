Vim Flog Plugin
===============

Personal version of fousa/vim-flog plugin.

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

`curl https://github.com/fousa/vim-flog/raw/master/plugin/flog.vim -o ~/.vim/plugin/flog.vim`

When this is done add `:silent exe "g:flog_enable"` to your .vimrc file.

Configuration
-------------

To change colors of sings, use the `higlight` command. The used groups are

* SignLowComplexity
* SignMediumComplexity
* SignHighComplexity

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
    `:call FlogEnable()`

* Turn off flog
    `:call FlogDisable()`

* Toggle flog
    `:call FlogToggle()`

Additionally, you can map this in your .vimrc:
    `:map ,f :call FlogToggle()<cr>`

Credits
-------

@garybernhardt's [pycomplexity.vim](http://bitbucket.org/garybernhardt/pycomplexity).

@topfunky's [rubycomplexity.el](https://github.com/topfunky/emacs-starter-kit/tree/master/vendor/ruby-complexity/)

@skammer's [Ruby Cyclomatic Complexity Plugin](https://github.com/skammer/vim-ruby-complexity)
