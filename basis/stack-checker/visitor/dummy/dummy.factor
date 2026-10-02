! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: stack-checker.visitor kernel ;
IN: stack-checker.visitor.dummy

M: false child-visitor f ;
M: false #introduce, drop ;
M: false #call, 3drop ;
M: false #call-recursive, 3drop ;
M: false #push, 2drop ;
M: false #shuffle, 5drop ;
M: false #>r, 2drop ;
M: false #r>, 2drop ;
M: false #return, drop ;
M: false #enter-recursive, 3drop ;
M: false #return-recursive, 3drop ;
M: false #terminate, 2drop ;
M: false #if, 3drop ;
M: false #dispatch, 2drop ;
M: false #phi, 3drop ;
M: false #declare, drop ;
M: false #recursive, 3drop ;
M: false #copy, 2drop ;
M: false #drop, drop ;
M: false #alien-invoke, 3drop ;
M: false #alien-indirect, 3drop ;
M: false #alien-assembly, 3drop ;
M: false #alien-callback, 2drop ;
