# VimCompletesMe

A super simple, super minimal, super light-weight tab-completion plugin for Vim.


Without configuration, the Tab key will, depending on the context, offer:

* Vim's local keyword completion
  ([Ctrl-X_Ctrl-N](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-N))
* File path completion when typing a path
  ([Ctrl-X_Ctrl-F](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-F))
* Omni-completion after typing a period.
  ([Ctrl-X_Ctrl-O](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-O))

With a `b:vcm_tab_complete` variable, you can set the Tab key to use the
following type of completions:

* Dictionary words
  ([Ctrl-X_Ctrl-K](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-K))
* User-defined completion
  ([Ctrl-X_Ctrl-U](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-U))
* Tags
  ([Ctrl-X_Ctrl-\]](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-]))
* Vim command line
  ([Ctrl-X_Ctrl-V](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-V))
* Omni completion
  ([Ctrl-X_Ctrl-O](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-O))

VimCompletesMe will even switch to keyword completion if none of the above
completions has any results. Simply hitting Tab again will switch the context
to keyword completion.

You can set the `b:vcm_tab_complete` variable interactively, or in an
autocommand:

    autocmd FileType text,markdown let b:vcm_tab_complete = 'dict'

Striving for minimalism, this plugin weighs under 70 lines of code.


## Installation
If you don't have a preferred installation method, I recommend installing
[pathogen.vim](https://github.com/tpope/vim-pathogen), and then simply copy and
paste:

    cd ~/.vim/bundle && git clone git://github.com/ajh17/VimCompletesMe.git

Once the helptags have been generated, see `:h VimCompletesMe` for usage.

## Thanks
* [bairui](https://github.com/dahu) for helping me with this plugin, and for
  the kickass name.
* You for using it!

## License
Copyright (c) Akshay Hegde. Distributed under the same terms as Vim itself. See
`:help license`
