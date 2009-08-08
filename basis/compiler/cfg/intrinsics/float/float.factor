! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.stacks compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.utilities ;
IN: compiler.cfg.intrinsics.float

: emit-float-op ( insn -- )
    [ 2inputs ] dip call ds-push ; inline

: emit-float-comparison ( cc -- )
    [ 2inputs ] dip ^^compare-float ds-push ; inline

: emit-float>fixnum ( -- )
    ds-pop ^^float>integer ^^tag-fixnum ds-push ;

: emit-fixnum>float ( -- )
    ds-pop ^^untag-fixnum ^^integer>float ds-push ;
