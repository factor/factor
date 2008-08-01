! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser words definitions kernel ;
IN: hints

: HINTS:
    scan-word
    [ +inlined+ changed-definition ]
    [ parse-definition "specializer" set-word-prop ] bi ;
    parsing
