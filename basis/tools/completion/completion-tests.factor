USING: assocs kernel sequences tools.completion tools.test ;

{ f } [ "abc" "def" fuzzy ] unit-test
{ V{ 4 5 6 } } [ "set-nth" "nth" fuzzy ] unit-test

{ { { 0 } { 4 5 6 } } } [ V{ 0 4 5 6 } runs [ { } like ] map ] unit-test

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

{ f } [ { "FROM:" } complete-vocab-words? ] unit-test
{ f } [ { "FROM:" "math" } complete-vocab-words? ] unit-test
{ t } [ { "FROM:" "math" "=>" } complete-vocab-words? ] unit-test
{ f } [ { "FROM:" "math" "=>" "+" ";" } complete-vocab-words? ] unit-test
{ f } [ { "BOOM:" "math" "=>" "+" } complete-vocab-words? ] unit-test

{ f } [ { "CHAR:" } complete-char? ] unit-test
{ t } [ { "CHAR:" "" } complete-char? ] unit-test
{ t } [ { "CHAR:" "a" } complete-char? ] unit-test

{ t } [ { "P\"" } complete-pathname? ] unit-test
{ t } [ { "P\"" "" } complete-pathname? ] unit-test
{ t } [ { "P\"" "~/" } complete-pathname? ] unit-test
{ f } [ { "P\"~/\"" "" } complete-pathname? ] unit-test
{ f } [ { "P\"~/\"" "asdf" } complete-pathname? ] unit-test
