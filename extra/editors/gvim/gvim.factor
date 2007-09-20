USING: kernel math math.parser namespaces editors.vim ;
IN: editors.gvim

TUPLE: gvim ;

M: gvim vim-command ( file line -- string )
    [
        "\"" % vim-path get % "\" --remote-tab-silent " %
        "+" % # " \"" % % "\"" %
    ] "" make ;

T{ gvim } vim-editor set-global
