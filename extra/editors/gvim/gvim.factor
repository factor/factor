USING: io.backend io.files kernel math math.parser
namespaces sequences system combinators
editors.vim editors.gvim.backend vocabs.loader ;
IN: editors.gvim

SINGLETON: gvim

M: gvim vim-command ( file line -- string )
    [ gvim-path , swap , "+" swap number>string append , ] { } make ;

t vim-detach set-global ! don't block the ui

gvim vim-editor set-global

{
    { [ os unix? ] [ "editors.gvim.unix" ] }
    { [ os windows? ] [ "editors.gvim.windows" ] }
} cond require
