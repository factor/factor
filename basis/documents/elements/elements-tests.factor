! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test namespaces documents documents.elements multiline ;
IN: document.elements.tests

SYMBOL: doc
<document> doc set
"123\nabcé" doc get set-doc-string

! char-elt
[ { 0 0 } ] [ { 0 0 } doc get char-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 1 } doc get char-elt prev-elt ] unit-test
[ { 0 3 } ] [ { 1 0 } doc get char-elt prev-elt ] unit-test
[ { 1 3 } ] [ { 1 5 } doc get char-elt prev-elt ] unit-test

[ { 1 5 } ] [ { 1 5 } doc get char-elt next-elt ] unit-test
[ { 0 2 } ] [ { 0 1 } doc get char-elt next-elt ] unit-test
[ { 1 0 } ] [ { 0 3 } doc get char-elt next-elt ] unit-test
[ { 1 5 } ] [ { 1 3 } doc get char-elt next-elt ] unit-test

! word-elt
<document> doc set
"Hello world\nanother line" doc get set-doc-string

[ { 0 0 } ] [ { 0 0 } doc get word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 2 } doc get word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 5 } doc get word-elt prev-elt ] unit-test
[ { 0 5 } ] [ { 0 6 } doc get word-elt prev-elt ] unit-test
[ { 0 6 } ] [ { 0 8 } doc get word-elt prev-elt ] unit-test
[ { 0 11 } ] [ { 1 0 } doc get word-elt prev-elt ] unit-test

[ { 0 5 } ] [ { 0 0 } doc get word-elt next-elt ] unit-test
[ { 0 6 } ] [ { 0 5 } doc get word-elt next-elt ] unit-test
[ { 0 11 } ] [ { 0 6 } doc get word-elt next-elt ] unit-test
[ { 1 0 } ] [ { 0 11 } doc get word-elt next-elt ] unit-test


! one-word-elt
[ { 0 0 } ] [ { 0 0 } doc get one-word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 2 } doc get one-word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 5 } doc get one-word-elt prev-elt ] unit-test
[ { 0 5 } ] [ { 0 2 } doc get one-word-elt next-elt ] unit-test
[ { 0 5 } ] [ { 0 5 } doc get one-word-elt next-elt ] unit-test

! line-elt
<document> doc set
"Hello\nworld, how are\nyou?" doc get set-doc-string

[ { 0 0 } ] [ { 0 3 } doc get line-elt prev-elt ] unit-test
[ { 0 3 } ] [ { 1 3 } doc get line-elt prev-elt ] unit-test
[ { 2 4 } ] [ { 2 1 } doc get line-elt next-elt ] unit-test

! one-line-elt
[ { 1 0 } ] [ { 1 3 } doc get one-line-elt prev-elt ] unit-test
[ { 1 14 } ] [ { 1 3 } doc get one-line-elt next-elt ] unit-test

! page-elt
<document> doc set
<" First line
Second line
Third line
Fourth line
Fifth line
Sixth line"> doc get set-doc-string

[ { 0 0 } ] [ { 3 3 } doc get 4 <page-elt> prev-elt ] unit-test
[ { 1 2 } ] [ { 5 2 } doc get 4 <page-elt> prev-elt ] unit-test

[ { 4 3 } ] [ { 0 3 } doc get 4 <page-elt> next-elt ] unit-test
[ { 5 10 } ] [ { 4 2 } doc get 4 <page-elt> next-elt ] unit-test

! doc-elt
[ { 0 0 } ] [ { 3 4 } doc get doc-elt prev-elt ] unit-test
[ { 5 10 } ] [ { 3 4 } doc get doc-elt next-elt ] unit-test
