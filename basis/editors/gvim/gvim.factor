USING: editors.vim io.backend kernel namespaces system
vocabs.loader ;
IN: editors.gvim

! This code builds on the code in editors.vim; see there for
! more information.

SINGLETON: gvim
gvim vim-editor set-global

HOOK: find-gvim-path io-backend ( -- path )
M: object find-gvim-path f ;

M: gvim find-vim-path find-gvim-path "gvim" or ;
M: gvim vim-detached? t ;
M: gvim vim-ui? t ;

os windows? [ "editors.gvim.windows" require ] when
