USING: accessors arrays assocs compiler.cfg
compiler.cfg.dataflow-analysis.private compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.registers
compiler.cfg.utilities compiler.cfg.stacks.vacant kernel math sequences sorting
tools.test vectors ;
IN: compiler.cfg.stacks.vacant.tests

{
    { { { } { 0 0 0 } } { { } { 0 } } }
} [
    { { 4 { 3 2 1 -3 0 -2 -1 } } { 0 { -1 } } } state>gc-data
] unit-test

! Replace -1, then gc. Peek is ok here because the -1 should be
! checked.
{ { 0 } } [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##peek { dst 0 } { loc D -1 } }
    }
    [ insns>cfg fill-in-gc-maps ]
    [ second gc-map>> check-d>> ] bi
] unit-test

! ! Replace -1, then gc. Peek is ok here because the -1 should be
! ! checked.
! { { 0 } } [
!     V{
!         T{ ##replace { src 10 } { loc D -1 } }
!         T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
!         T{ ##peek { dst 0 } { loc D -1 } }
!     }
!     [ insns>cfg compute-vacant-sets ]
!     [ second gc-map>> check-d>> ] bi
! ] unit-test

! ! Should not be ok because the value wasn't initialized when gc ran.
! [
!     V{
!         T{ ##inc-d f 1 }
!         T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
!         T{ ##peek { dst 0 } { loc D 0 } }
!     } insns>cfg
!     compute-vacant-sets
! ] [ vacant-peek? ] must-fail-with

! visit-insn should set the gc info.
{ { 0 0 } { } } [
    { { 2 { } } { 0 { } } }
    T{ ##alien-invoke { gc-map T{ gc-map } } }
    [ gc-map>> set-gc-map ] keep gc-map>> [ scrub-d>> ] [ scrub-r>> ] bi
] unit-test


! ! read-ok?
! { t } [
!     0 { 0 { 0 1 2 } } read-ok?
! ] unit-test

! { f } [
!     2 { 3 { } } read-ok?
! ] unit-test

! { f } [
!     -1 { 3 { } } read-ok?
! ] unit-test

! ! { f } [
! !     4 { 3 { } } read-ok?
! ! ] unit-test

! { t } [
!     4 { 0 { } } read-ok?
! ] unit-test

! { t } [
!     4 { 1 { 0 } } read-ok?
! ] unit-test

! ! Uninitialized peeks
! [
!     V{
!         T{ ##inc-d f 1 }
!         T{ ##peek { dst 0 } { loc D 0 } }
!     } insns>cfg
!     compute-vacant-sets
! ] [ vacant-peek? ] must-fail-with

! [
!     V{
!         T{ ##inc-r f 1 }
!         T{ ##peek { dst 0 } { loc R 0 } }
!     } insns>cfg
!     compute-vacant-sets
! ] [ vacant-peek? ] must-fail-with

! ! Here again the peek refers to a parameter word, but there are
! ! uninitialized stack locations. That probably isn't ok.
! [
!     V{
!         T{ ##inc-d f 3 }
!         T{ ##peek { dst 0 } { loc D 3 } }
!     } insns>cfg
!     compute-vacant-sets
! ] [ vacant-peek? ] must-fail-with


! ! Should not be ok because the value wasn't initialized when gc ran.
! ! [
! !     V{
! !         T{ ##inc-d f 1 }
! !         T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
! !         T{ ##peek { dst 0 } { loc D 0 } }
! !     } insns>cfg
! !     compute-map-sets
! ! ] [ vacant-peek? ] must-fail-with
