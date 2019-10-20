! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bit-arrays classes growable kernel math parser
prettyprint.custom sequences sequences.private vectors.functor
vocabs.loader ;
IN: bit-vectors

VECTORIZED: bit bit-array <bit-array>

SYNTAX: \?V{ \ \} [ >bit-vector ] parse-literal ;

M: bit-vector contract 2drop ;

{ "bit-vectors" "prettyprint" } "bit-vectors.prettyprint" require-when
