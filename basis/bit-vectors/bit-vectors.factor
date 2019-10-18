! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable bit-arrays prettyprint.custom
parser accessors vectors.functor classes.parser ;
IN: bit-vectors

<< "bit-vector" create-class-in \ bit-array \ <bit-array> define-vector >>

SYNTAX: ?V{ \ } [ >bit-vector ] parse-literal ;

M: bit-vector contract 2drop ;
M: bit-vector >pprint-sequence ;
M: bit-vector pprint-delims drop \ ?V{ \ } ;
M: bit-vector pprint* pprint-object ;
