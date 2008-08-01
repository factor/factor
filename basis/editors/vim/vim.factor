USING: definitions io io.launcher kernel math math.parser
namespaces parser prettyprint sequences editors accessors ;
IN: editors.vim

SYMBOL: vim-path

SYMBOL: vim-editor
HOOK: vim-command vim-editor ( file line -- array )

SINGLETON: vim

M: vim vim-command
    [
        vim-path get , swap , "+" swap number>string append ,
    ] { } make ;

: vim-location ( file line -- )
    vim-command try-process ;

"vim" vim-path set-global
[ vim-location ] edit-hook set-global
vim vim-editor set-global
