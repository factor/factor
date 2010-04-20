! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: javascriptcore.ffi.hack kernel ;
IN: javascriptcore

: with-javascriptcore ( quot -- )
    set-callstack-bounds
    call ; inline
