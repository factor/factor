! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.stacks compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.utilities ;
IN: compiler.cfg.intrinsics.float

: emit-float-op ( insn -- )
    [ 2inputs ] dip call ds-push ; inline

: emit-float-ordered-comparison ( cc -- )
    [ 2inputs ] dip ^^compare-float-ordered ds-push ; inline

: emit-float-unordered-comparison ( cc -- )
    [ 2inputs ] dip ^^compare-float-unordered ds-push ; inline

: emit-float>fixnum ( -- )
    ds-pop ^^float>integer ^^tag-fixnum ds-push ;

: emit-fixnum>float ( -- )
    ds-pop ^^untag-fixnum ^^integer>float ds-push ;

: emit-fsqrt ( -- )
    ds-pop ^^sqrt ds-push ;

: emit-unary-float-function ( func -- )
    [ ds-pop ] dip ^^unary-float-function ds-push ;

: emit-binary-float-function ( func -- )
    [ 2inputs ] dip ^^binary-float-function ds-push ;
