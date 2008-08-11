! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes.tuple classes.tuple.private math arrays 
byte-arrays words stack-checker.known-words ;
IN: compiler.tree.intrinsics

: <immutable-tuple-boa> ( ... class -- tuple )
    "BUG: missing <immutable-tuple-boa> intrinsic" throw ;

: (tuple) ( layout -- tuple )
    "BUG: missing (tuple) intrinsic" throw ;

\ (tuple) { tuple-layout } { tuple } define-primitive
\ (tuple) make-flushable

: (array) ( n -- array )
    "BUG: missing (array) intrinsic" throw ;

\ (array) { integer } { array } define-primitive
\ (array) make-flushable

: (byte-array) ( n -- byte-array )
    "BUG: missing (byte-array) intrinsic" throw ;

\ (byte-array) { integer } { byte-array } define-primitive
\ (byte-array) make-flushable
