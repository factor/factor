USING: io.backend io.files kernel math math.parser
namespaces sequences system combinators
editors.vim vocabs.loader make ;
IN: editors.gvim

! This code builds on the code in editors.vim; see there for
! more information.

SINGLETON: gvim

HOOK: gvim-path io-backend ( -- path )

M: gvim vim-command ( file line -- string )
    [
        gvim-path ,
        number>string "+" prepend , ,
    ] { } make ;

gvim vim-editor set-global

{
    { [ os unix? ] [ "editors.gvim.unix" ] }
    { [ os windows? ] [ "editors.gvim.windows" ] }
} cond require
