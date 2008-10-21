! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.stacks compiler.cfg.hats ;
IN: compiler.cfg.intrinsics.float

: emit-float-op ( insn -- )
    [ 2inputs [ ^^unbox-float ] bi@ ] dip call ^^box-float
    ds-push ; inline

: emit-float-comparison ( cc -- )
    [ 2inputs [ ^^unbox-float ] bi@ ] dip ^^compare-float
    ds-push ; inline

: emit-float>fixnum ( -- )
    ds-pop ^^unbox-float ^^float>integer ^^tag-fixnum ds-push ;

: emit-fixnum>float ( -- )
    ds-pop ^^untag-fixnum ^^integer>float ^^box-float ds-push ;
