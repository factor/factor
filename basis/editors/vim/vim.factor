USING: editors io.standard-paths kernel make math.parser
namespaces sequences strings ;
IN: editors.vim

TUPLE: vim ;

editor-class [ T{ vim } ] initialize

SYMBOL: vim-path

HOOK: find-vim-path editor-class ( -- path )

HOOK: vim-ui? editor-class ( -- ? )

SYMBOL: vim-tabs?

M: vim vim-ui? f ;

M: vim find-vim-path "vim" ?find-in-path ;

: actual-vim-path ( -- path )
    \ vim-path get [ find-vim-path ] unless* ;

M: vim editor-command
    [
        actual-vim-path dup string? [ , ] [ % ] if
        vim-ui? [ "-g" , ] when
        vim-tabs? get [ "--remote-tab-silent" , ] when
        number>string "+" prepend ,
        ,
    ] { } make ;

M: vim editor-detached? f ;
