USING: editors io.backend io.launcher kernel make math.parser
namespaces sequences strings system vocabs.loader ;
IN: editors.vim

SYMBOL: vim-editor

SINGLETON: vim
\ vim vim-editor set-global

SYMBOL: vim-path

HOOK: find-vim-path vim-editor ( -- path )
HOOK: vim-detached? vim-editor ( -- detached? )


M: vim find-vim-path "vim" ;
M: vim vim-detached? f ;

: actual-vim-path ( -- path )
    \ vim-path get-global [ find-vim-path ] unless* ;

: vim-command ( file line -- command )
    [
        actual-vim-path dup string? [ , ] [ % ] if
        [ , ] [ number>string "+" prepend , ] bi*
    ] { } make ;

: vim ( file line -- )
    vim-command vim-detached? [ run-detached ] [ run-process ] if drop ;

[ vim ] edit-hook set-global
