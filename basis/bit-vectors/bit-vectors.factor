! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: bit-arrays classes.parser growable kernel parser
vectors.functor vocabs.loader ;
IN: bit-vectors

<< "bit-vector" create-class-in \ bit-array \ <bit-array> define-vector >>

SYNTAX: ?V{ \ } [ >bit-vector ] parse-literal ;

M: bit-vector contract 2drop ;

{ "bit-vectors" "prettyprint" } "bit-vectors.prettyprint" require-when
