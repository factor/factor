! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar io io.backend io.encodings.utf8
io.launcher ;
IN: build-support

CONSTANT: factor.sh-path "resource:build-support/factor.sh"

: factor.sh-make-target ( -- string )
    <process>
        factor.sh-path normalize-path "make-target" 2array >>command
        10 seconds >>timeout
    utf8 [ readln ] with-process-reader ;
