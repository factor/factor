USING: definitions io io.launcher kernel math math.parser
namespaces parser prettyprint sequences editors accessors ;
IN: editors.vim

SYMBOL: vim-path
SYMBOL: vim-detach

SYMBOL: vim-editor
HOOK: vim-command vim-editor ( file line -- array )

TUPLE: vim ;

M: vim vim-command
    [
        vim-path get , swap , "+" swap number>string append ,
    ] { } make ;

: vim-location ( file line -- )
    vim-command
    <process> swap >>command
    vim-detach get-global [ t >>detached ] when
    try-process ;

"vim" vim-path set-global
[ vim-location ] edit-hook set-global
T{ vim } vim-editor set-global
