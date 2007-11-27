USING: kernel math math.parser namespaces editors.vim ;
IN: editors.gvim

TUPLE: gvim ;

M: gvim vim-command ( file line -- string )
    [ "\"" % vim-path get % "\" \"" % swap % "\" +" % # ] "" make ;

T{ gvim } vim-editor set-global
"gvim" vim-path set-global
