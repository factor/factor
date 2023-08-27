! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: fuel.help fuel.help.private help help.topics sequences
tools.test ;
USE: io.servers ! required for a test to pass

{
    {
        { $prev-link word-help* "word-help* ( word -- content )" }
        { $next-link articles "articles" }
    }
} [
    \ lookup-article word-element third
    [ first { $prev-link $next-link } member? ] filter
] unit-test

{ { $next-link POSTPONE: unit-test "unit-test" } } [
    \ unit-test >link \ $next-link next/prev-link
] unit-test

{
    { describe-words f }
} [
    "help.handbook" vocab-describe-words
] unit-test

{ f t } [
    "io" vocab-help-article?
    "help.lint" vocab-help-article?
] unit-test

{
    { "handbook" "io.servers" }
} [
    "server-config" article-parents
] unit-test

{
    {
        { "handbook" "Factor handbook" article }
        { "first-program" "Your first program" article }
    }
} [
    "first-program-test" article-crumbs
] unit-test
