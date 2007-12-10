USING: io.backend io.files kernel math math.parser
namespaces editors.vim sequences system ;
IN: editors.gvim

TUPLE: gvim ;

HOOK: gvim-path io-backend ( -- path )


M: gvim vim-command ( file line -- string )
    [ "\"" % gvim-path % "\" \"" % swap % "\" +" % # ] "" make ;

t vim-detach set-global ! don't block the ui

T{ gvim } vim-editor set-global

USE-IF: unix? editors.gvim.unix
USE-IF: windows? editors.gvim.windows
