! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors command-line continuations formatting io
io.directories io.files.info io.pathnames kernel locals math
namespaces sequences sorting ;
IN: tools.tree

SYMBOL: #files
SYMBOL: #directories

: indent ( indents -- )
    unclip-last-slice
    [ [ "    " "|   " ? write ] each ]
    [ "└── " "├── " ? write ] bi* ;

: write-name ( entry indents -- )
    indent name>> write ;

: write-file ( entry indents -- )
    write-name #files [ 1 + ] change-global ;

DEFER: write-tree

: write-dir ( entry indents -- )
    [ write-name ] [
        [ [ name>> ] dip write-tree ]
        [ 3drop " [error opening dir]" write ] recover
    ] 2bi #directories [ 1 + ] change-global ;

: write-entry ( entry indents -- )
    nl over directory? [ write-dir ] [ write-file ] if ;

:: write-tree ( path indents -- )
    path [
        [ name>> ] sort-by [ ] [
            unclip-last [
                f indents push
                [ indents write-entry ] each
            ] [
                indents pop* t indents push
                indents write-entry
            ] bi* indents pop*
        ] if-empty
    ] with-directory-entries ;

: tree ( path -- )
    0 #directories set-global 0 #files set-global
    [ write ] [ V{ } clone write-tree ] bi nl
    #directories get-global #files get-global
    "\n%d directories, %d files\n" printf ;

: run-tree ( -- )
    command-line get [
        "." tree
    ] [
        [ tree ] each
    ] if-empty ;

MAIN: run-tree
