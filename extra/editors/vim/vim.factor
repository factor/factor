USING: definitions io io.launcher kernel math math.parser
namespaces parser prettyprint sequences editors ;
IN: editors.vim

SYMBOL: vim-path
SYMBOL: vim-detach

SYMBOL: vim-editor
HOOK: vim-command vim-editor

TUPLE: vim ;

M: vim vim-command ( file line -- string )
    [ "\"" % vim-path get % "\" \"" % swap % "\" +" % # ] "" make ;

: vim-location ( file line -- )
    vim-command
    vim-detach get-global
    [ run-detached ] [ run-process ] if ;

"vim" vim-path set-global
[ vim-location ] edit-hook set-global
T{ vim } vim-editor set-global
