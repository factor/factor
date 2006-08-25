IN: vim
USING: definitions embedded io kernel parser prettyprint process
sequences namespaces ;

: file-modified stat fourth ;

: vim-location ( file line -- )
    >r [ file-modified ] keep r>
    [ "vim \"" % over % "\" +" % # ] "" make system drop
    file-modified = [ drop ] [ run-file ] if ;

: vim ( spec -- )
    #! Edit the file in vim.  Rerun the file if the timestamp is changed.
    dup where first2 vim-location ;

[ vim-location ] edit-hook set-global

: vim-syntax
    #! Generate a new factor.vim file for syntax highlighting
    "contrib/vim/factor.vim.fgen" "factor.vim" embedded-convert ;

