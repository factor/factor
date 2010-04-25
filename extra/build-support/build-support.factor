! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io io.backend io.encodings.utf8 io.launcher ;
IN: build-support

CONSTANT: factor.sh-path "resource:build-support/factor.sh"

: factor.sh-make-target ( -- string )
    factor.sh-path normalize-path "make-target" 2array
    utf8 [ readln ] with-process-reader ;
