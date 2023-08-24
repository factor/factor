USING: editors.vim io.backend io.standard-paths kernel
namespaces system vocabs editors ;
IN: editors.gvim

! This code builds on the code in editors.vim; see there for
! more information.

SINGLETON: gvim

INSTANCE: gvim vim-base

HOOK: find-gvim-path io-backend ( -- path )

M: object find-gvim-path f ;

M: windows find-gvim-path
    { "vim" } "gvim.exe" find-in-applications ;

M: gvim find-vim-path
    find-gvim-path [ "gvim" ?find-in-path ] unless* ;

M: gvim vim-ui? t ;

M: gvim editor-detached? t ;
