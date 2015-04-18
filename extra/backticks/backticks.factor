! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: fry io io.encodings.utf8 io.launcher multiline sequences
unicode.categories ;
IN: backticks

SYNTAX: `
    "`" parse-multiline-string [ blank? ] trim
    '[ _ utf8 [ contents ] with-process-reader ]
    append! ;
