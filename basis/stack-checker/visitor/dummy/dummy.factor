! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: stack-checker.visitor kernel ;
IN: stack-checker.visitor.dummy

M: f child-visitor f ;
M: f #introduce, drop ;
M: f #call, 3drop ;
M: f #call-recursive, 3drop ;
M: f #push, 2drop ;
M: f #shuffle, 5drop ;
M: f #>r, 2drop ;
M: f #r>, 2drop ;
M: f #return, drop ;
M: f #enter-recursive, 3drop ;
M: f #return-recursive, 3drop ;
M: f #terminate, 2drop ;
M: f #if, 3drop ;
M: f #dispatch, 2drop ;
M: f #phi, 3drop ;
M: f #declare, drop ;
M: f #recursive, 3drop ;
M: f #copy, 2drop ;
M: f #drop, drop ;
M: f #alien-invoke, 3drop ;
M: f #alien-indirect, 3drop ;
M: f #alien-assembly, 3drop ;
M: f #alien-callback, 2drop ;
