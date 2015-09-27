! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.hats compiler.cfg.stacks fry ;
IN: compiler.cfg.intrinsics.float

: emit-float-ordered-comparison ( cc -- )
    '[ _ ^^compare-float-ordered ] binary-op ; inline

: emit-float-unordered-comparison ( cc -- )
    '[ _ ^^compare-float-unordered ] binary-op ; inline
