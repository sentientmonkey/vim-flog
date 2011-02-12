Vim Flog Plugin
===============

_(Forked from [Ruby Cyclomatic Complexity Plugin](https://github.com/skammer/vim-ruby-complexity) created by @skammer)_

Indicates the Flog number in front of the action in your Ruby code to indicate the complexity.

![Screen shot](http://10to1.blog.s3.amazonaws.com/vim-flog.png)

Requirements
------------

* ruby
* flog rubygem
* vim 7.2+, compiled with:
  * +ruby
  * +signs

Installation
------------

First of all make sure you have a Vim installed with Ruby support. If you use MacVim than you can build your own version of Vim like [this](https://github.com/b4winckler/macvim/wiki/Building).

Install the Flog gem like this: `gem install flog`.

To install the plugin just run this command in your Terminal:

`curl https://github.com/fousa/vim-flog/raw/master/plugin/flog.vim -o ~/.vim/plugin/flog.vim`

When this is done add `:silent exe "g:flog_enable"` to your .vimrc file.

Configuration
-------------

You can set the colors for the complexity indication with the following commands in your .vimrc:

* Set the color of for low complexity: <br/>
    `let g:flog_low_color="#a5c261"`

* Set the color of for medium complexity: <br/>
    `let g:flog_medium_color="#ffc66d"`

* Set the color of for high complexity: <br/>
    `let g:flog_high_color="#cc7833"`

* Set the background color: <br/>
    `let g:flog_background_color="#323232"`

You can set the limits for the complexity indication with the following commands in your .vimrc:

* Set the limit to switch to a medium complexity: <br/>
    `let g:flog_medium_limit=10`

* Set the limit to switch to a high complexity: <br/>
    `let g:flog_high_limit=20`

Credits
-------

@garybernhardt's [pycomplexity.vim](http://bitbucket.org/garybernhardt/pycomplexity).

@topfunky's [rubycomplexity.el](https://github.com/topfunky/emacs-starter-kit/tree/master/vendor/ruby-complexity/)

@skammer's [Ruby Cyclomatic Complexity Plugin](https://github.com/skammer/vim-ruby-complexity)
