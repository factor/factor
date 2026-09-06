! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: effects.parser kernel parser stack-checker words ;
IN: syntax.inferred

<PRIVATE

: (?:) ( -- word def effect )
    [ scan-new-word parse-definition dup infer ] with-definition ;

PRIVATE>

SYNTAX: ?: (?:) define-declared ;
