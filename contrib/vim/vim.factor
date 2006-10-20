IN: vim
USING: definitions embedded io kernel namespaces parser prettyprint process
sequences ;

SYMBOL: vim-path

"vim" vim-path set-global

: vim-command ( file line -- string )
    [ "\"" % vim-path get % "\" \"" % swap % "\" +" % # ] "" make ;

: vim-location ( file line -- )
    vim-command run-process ;

: vim ( spec -- )
    #! Edit the file in vim.  Rerun the file if the timestamp is changed.
    where first2 vim-location ;

[ vim-location ] edit-hook set-global

: vim-syntax
    #! Generate a new factor.vim file for syntax highlighting
    "contrib/vim/factor.vim.fgen" "factor.vim" embedded-convert ;

