! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.stacks compiler.cfg.hats ;
IN: compiler.cfg.intrinsics.float

: emit-float-op ( insn -- )
    [ 2phantom-pop [ ^^unbox-float ] bi@ ] dip call ^^box-float
    phantom-push ; inline

: emit-float-comparison ( cc -- )
    [ 2phantom-pop [ ^^unbox-float ] bi@ ] dip ^^compare-float
    phantom-push ; inline

: emit-float>fixnum ( -- )
    phantom-pop ^^unbox-float ^^float>integer ^^tag-fixnum phantom-push ;

: emit-fixnum>float ( -- )
    phantom-pop ^^untag-fixnum ^^integer>float ^^box-float phantom-push ;
