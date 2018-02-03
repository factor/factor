USING: help.lint.coverage help.lint.coverage.private help.markup
help.syntax kernel math.matrices sorting tools.test vocabs ;
IN: help.lint.coverage.tests

<PRIVATE
: empty ( a v -- x y ) ;
: nonexistent ( a v -- x y ) ;
: defined ( x -- x ) ;

HELP: empty { $examples } ;
HELP: nonexistent ;
HELP: defined { $examples { $example "USING: x ;" "blah" "hahaha" } } ;
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

{ eye } [ "eye" loaded-vocab-names resolve-name-in ] unit-test
