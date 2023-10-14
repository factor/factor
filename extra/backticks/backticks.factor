! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: interpolate io.launcher multiline sequences ;
IN: backticks

SYNTAX: `
    "`" parse-multiline-string '[
        _ interpolate>string process-contents
    ] append! ;
