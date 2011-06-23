USING: definitions io io.launcher kernel math math.parser
namespaces parser prettyprint sequences editors accessors
make strings ;
IN: editors.vim

SYMBOL: vim-path
SYMBOL: vim-editor
HOOK: vim-command vim-editor ( file line -- array )

SINGLETON: vim

M: vim vim-command
    [
        vim-path get dup string? [ , ] [ % ] if
        [ , ] [ number>string "+" prepend , ] bi*
    ] { } make ;

: vim ( file line -- )
    vim-command run-process drop ;

"vim" vim-path set-global
[ vim ] edit-hook set-global
\ vim vim-editor set-global
