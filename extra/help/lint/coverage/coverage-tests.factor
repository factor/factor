USING: accessors help.lint.coverage help.lint.coverage.private 
help.markup help.syntax kernel literals math math.matrices 
sequences sorting tools.test vocabs ;
IN: help.lint.coverage.tests

<PRIVATE
: empty ( a v -- x y ) ;
: nonexistent ( a v -- x y ) ;
: defined ( x -- x ) ;

HELP: empty { $examples } ;
HELP: nonexistent ;
HELP: defined { $examples { $example "USING: prettyprint ; " "1 ." "1" } } ;
PRIVATE>

{ t } [ \ empty empty-examples? ] unit-test
{ f } [ \ nonexistent empty-examples? ] unit-test
{ f } [ \ defined empty-examples? ] unit-test
{ f } [ \ keep empty-examples? ] unit-test

{ { $description $values } } [ \ empty missing-sections natural-sort ] unit-test
{ { $description $values } } [ \ defined missing-sections natural-sort ] unit-test
{ { } } [ \ keep missing-sections ] unit-test

{ { "a.b" "a.b.c" } } [ { "a.b" "a.b.private" "a.b.c.private" "a.b.c" } filter-private ] unit-test

{ "sections" } [ 0 "section" ?pluralize ] unit-test
{ "section" } [ 1 "section" ?pluralize ] unit-test
{ "sections" } [ 10 "section" ?pluralize ] unit-test

{ { $examples } } [ \ empty word-defines-sections ] unit-test
{ { $examples } } [ \ defined word-defines-sections ] unit-test
{ { } } [ \ nonexistent word-defines-sections ] unit-test
{ { $values $description $examples } } [ \ keep word-defines-sections ] unit-test
{ { $values $contract $examples } } [ \ <word-help-coverage> word-defines-sections ] unit-test

{ empty } [ "empty" find-word ] unit-test

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
  V{ "needs help " "sections: " { { "$description" $description } { "$examples" $examples } } }
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
! the contents of all-words is not important
{ } [ all-words [ <word-help-coverage> ] map drop ] unit-test
