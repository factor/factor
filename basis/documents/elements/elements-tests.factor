! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test namespaces documents documents.elements ;
IN: document.elements.tests

<document> "doc" set
"Hello world" "doc" get set-doc-string
[ { 0 0 } ] [ { 0 0 } "doc" get one-word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 2 } "doc" get one-word-elt prev-elt ] unit-test
[ { 0 0 } ] [ { 0 5 } "doc" get one-word-elt prev-elt ] unit-test
[ { 0 5 } ] [ { 0 2 } "doc" get one-word-elt next-elt ] unit-test
[ { 0 5 } ] [ { 0 5 } "doc" get one-word-elt next-elt ] unit-test

<document> "doc" set
"Hello\nworld, how are\nyou?" "doc" get set-doc-string

[ { 2 4 } ] [ "doc" get doc-end ] unit-test

[ { 0 0 } ] [ { 0 3 } "doc" get line-elt prev-elt ] unit-test
[ { 0 3 } ] [ { 1 3 } "doc" get line-elt prev-elt ] unit-test
[ { 2 4 } ] [ { 2 1 } "doc" get line-elt next-elt ] unit-test
