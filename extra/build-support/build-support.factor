! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar io io.backend io.encodings.utf8
io.launcher ;
IN: build-support

: build-make-target ( -- string )
    <process>
        "resource:build.sh" normalize-path "make-target" 2array >>command
        10 seconds >>timeout
    utf8 [ readln ] with-process-reader ;
