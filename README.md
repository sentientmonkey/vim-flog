Vim Flog Plugin
===============

Indicates the Flog number in front of the action in your Ruby code to indicate the complexity.

![Screen shot](https://github.com/skammer/vim-ruby-complexity/raw/master/Screen%20shot%202010-11-29%20at%2013.23.46.png)

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

To install the plugin just run this command in your Terminal:

`curl https://github.com/fousa/vim-flog/raw/master/plugin/flog.vim -o ~/piep.vim`

When this is done add `:silent exe "g:flog_enable"` to your .vimrc file.

Configuration
-------------

You can set the colors for the complexity indication with the following commands in your .vimrc:

- Set the color of for low complexity: <br/>
    `let g:flog_low_color="#000000"`

- Set the color of for medium complexity: <br/>
    `let g:flog_medium_color="#000000"`

- Set the color of for high complexity: <br/>
    `let g:flog_high_color="#000000"`

You can set the limits for the complexity indication with the following commands in your .vimrc:

- Set the limit to switch to a medium complexity: <br/>
    `let g:flog_medium_limit=10`

- Set the limit to switch to a high complexity: <br/>
    `let g:flog_high_limit=30`

Credits
-------

@garybernhardt's [pycomplexity.vim](http://bitbucket.org/garybernhardt/pycomplexity).

@topfunky's [rubycomplexity.el](https://github.com/topfunky/emacs-starter-kit/tree/master/vendor/ruby-complexity/)

