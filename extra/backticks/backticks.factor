! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: fry io io.encodings.utf8 interpolate io.launcher
multiline sequences ;
IN: backticks

SYNTAX: `
    "`" parse-multiline-string '[
        _ interpolate>string
        utf8 [ read-contents ] with-process-reader
    ] append! ;
