IN: vim
REQUIRES: process ;
USING: io kernel parser prettyprint process sequences ;

: file-modified stat fourth ;

: vim-line/file ( file line -- )
    >r "vim " swap append r> unparse " +" swap append3 system drop ;

: vim ( spec -- )
    #! Edit the file in vim.  Rerun the file if the timestamp is changed.
    dup where first2 >r ?resource-path [ file-modified ] keep r>
    [ vim-line/file ] 2keep drop file-modified = [ drop ] [ reload ] if ;

