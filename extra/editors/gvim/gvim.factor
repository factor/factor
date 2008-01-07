USING: io.backend io.files kernel math math.parser
namespaces editors.vim sequences system combinators
vocabs.loader ;
IN: editors.gvim

TUPLE: gvim ;

HOOK: gvim-path io-backend ( -- path )


M: gvim vim-command ( file line -- string )
    [ "\"" % gvim-path % "\" \"" % swap % "\" +" % # ] "" make ;

t vim-detach set-global ! don't block the ui

T{ gvim } vim-editor set-global

{
    { [ unix? ] [ "editors.gvim.unix" ] }
    { [ windows? ] [ "editors.gvim.windows" ] }
} cond require
