
USING: assocs kernel tools.completion tools.completion.private
tools.test ;

IN: tools.completion

{ f } [ "abc" "def" fuzzy ] unit-test
{ V{ 4 5 6 } } [ "set-nth" "nth" fuzzy ] unit-test

{ V{ V{ 0 } V{ 4 5 6 } } } [ V{ 0 4 5 6 } runs ] unit-test

{ { "nth" "?nth" "set-nth" } } [
    "nth" { "set-nth" "nth" "?nth" } dup zip completions keys
] unit-test

{ { "a" "b" "c" "d" "e" "f" "g" } } [
    "" { "a" "b" "c" "d" "e" "f" "g" } dup zip completions keys
] unit-test

{ f } [ { "USE:" "A" "B" "C" } complete-vocab? ] unit-test
{ f } [ { "USE:" "A" "B" } complete-vocab? ] unit-test
{ f } [ { "USE:" "A" "" } complete-vocab? ] unit-test
{ t } [ { "USE:" "A" } complete-vocab? ] unit-test
{ t } [ { "USE:" "" } complete-vocab? ] unit-test
{ f } [ { "USE:" } complete-vocab? ] unit-test
{ t } [ { "UNUSE:" "A" } complete-vocab? ] unit-test
{ t } [ { "QUALIFIED:" "A" } complete-vocab? ] unit-test
{ t } [ { "QUALIFIED-WITH:" "A" } complete-vocab? ] unit-test
{ t } [ { "USING:" "A" "B" "C" } complete-vocab? ] unit-test
{ f } [ { "USING:" "A" "B" "C" ";" } complete-vocab? ] unit-test
{ t } [ { "X" ";" "USING:" "A" "B" "C" } complete-vocab? ] unit-test

{ f } [ { "CHAR:" } complete-CHAR:? ] unit-test
{ t } [ { "CHAR:" "" } complete-CHAR:? ] unit-test
{ t } [ { "CHAR:" "a" } complete-CHAR:? ] unit-test
