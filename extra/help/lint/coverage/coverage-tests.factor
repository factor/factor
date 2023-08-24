USING: accessors english eval help.lint.coverage
help.lint.coverage.private help.markup help.syntax kernel
literals math math.matrices multiline sequences sorting
tools.test vocabs ;
IN: help.lint.coverage.tests

<PRIVATE
: an-empty-word-with-a-unique-name ( a v -- x y ) ;
: a-nonexistent-word ( a v -- x y ) ;
: a-defined-word ( x -- x ) ;

HELP: an-empty-word-with-a-unique-name { $examples } ;
HELP: a-nonexistent-word ;
HELP: a-defined-word { $examples { $example "USING: prettyprint ; " "1 ." "1" } } ;
PRIVATE>

{ t } [ \ an-empty-word-with-a-unique-name empty-examples? ] unit-test
{ f } [ \ a-nonexistent-word empty-examples? ] unit-test
{ f } [ \ a-defined-word empty-examples? ] unit-test
{ f } [ \ keep empty-examples? ] unit-test

{ { $description $values } } [ \ an-empty-word-with-a-unique-name missing-sections sort ] unit-test
{ { $description $values } } [ \ a-defined-word missing-sections sort ] unit-test
{ { } } [ \ keep missing-sections ] unit-test

{ { "a.b" "a.b.c" } } [ { "a.b" "a.b.private" "a.b.c.private" "a.b.c" } filter-private ] unit-test

{ "sections" } [ 0 "section" ?pluralize ] unit-test
{ "section" } [ 1 "section" ?pluralize ] unit-test
{ "sections" } [ 10 "section" ?pluralize ] unit-test

{ { $examples } } [ \ an-empty-word-with-a-unique-name word-defines-sections ] unit-test
{ { $examples } } [ \ a-defined-word word-defines-sections ] unit-test
{ { } } [ \ a-nonexistent-word word-defines-sections ] unit-test
{ { $values $description $examples } } [ \ keep word-defines-sections ] unit-test
{ { $values $contract $examples } } [ \ <word-help-coverage> word-defines-sections ] unit-test

{ an-empty-word-with-a-unique-name } [ "an-empty-word-with-a-unique-name" find-word ] unit-test

{ { } } [ \ zero-matrix? missing-sections ] unit-test
{ t } [ \ word-help-coverage? <word-help-coverage> 100%-coverage?>> ] unit-test
{ t } [ \ zero-matrix? <word-help-coverage> 100%-coverage?>> ] unit-test

{
  V{ "[" { $[ "math" dup lookup-vocab ] } "] " { "zero?" zero? } ": " }
} [
  V{ } clone \ zero? (assemble-word-metadata)
] unit-test
{
  V{ "empty " { "$examples" $examples } "; " }
} [
  V{ } clone word-help-coverage new t >>empty-examples? (assemble-empty-examples)
] unit-test

{
  V{ "needs help " "sections: " { { "$description" $description } " and " { "$examples" $examples } } }
} [
  V{ } clone word-help-coverage new { $description $examples } >>omitted-sections (assemble-omitted-sections)
] unit-test
{
  V{ "needs help " "section: " { { "$description" $description } } }
} [
  V{ } clone word-help-coverage new { $description } >>omitted-sections (assemble-omitted-sections)
] unit-test
{
  V{ "full help coverage" }
} [
  V{ } clone word-help-coverage new t >>100%-coverage? (assemble-full-coverage)
] unit-test

! make sure this doesn't throw an error (would signify an issue with ignored-words)
[ { $io-error $prettyprinting-note $nl } [ <word-help-coverage> ] map ] must-not-fail


! Lint system is written weirdly, there's no way to invoke it and get the output
! Instead, it writes to lint-failures.
{ t }
[
    [[
        USING: assocs definitions math kernel namespaces help.syntax
        help.lint help.lint.private continuations compiler.units ;
        IN: help.lint.tests
        <<
        : add-stuff ( x y -- z ) + ;

        HELP: add-stuff ;
        >>
        [
            H{ } clone lint-failures [
                \ add-stuff check-word lint-failures get
                assoc-empty? [ "help-lint is broken" throw ] when
            ] with-variable t
        ] [
            [ \ add-stuff forget ] with-compilation-unit
        ] [
            f
        ] cleanup
    ]] eval( -- ? )
] unit-test


! clean up broken words
[[
  USING: definitions compiler.units ;
  IN: help.lint.coverage.tests.private
[
    \ an-empty-word-with-a-unique-name forget
    \ a-nonexistent-word forget
    \ a-defined-word forget
] with-compilation-unit
]] eval( -- )
