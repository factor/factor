! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: fuel.help.private help help.topics sequences tools.test ;
IN: fuel.help.tests

{
    {
        { $prev-link word-help* "word-help* ( word -- content )" }
        { $next-link articles "articles" }
    }
} [
    \ lookup-article (fuel-word-element) third
    [ first { $prev-link $next-link } member? ] filter
] unit-test

{ { $next-link POSTPONE: unit-test "unit-test" } } [
    \ unit-test >link \ $next-link next/prev-link
] unit-test
