! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes.tuple classes.tuple.private math arrays 
byte-arrays words stack-checker.known-words ;
IN: compiler.intrinsics

ERROR: missing-intrinsic ;

: (tuple) ( n -- tuple ) missing-intrinsic ;

\ (tuple) { tuple-layout } { tuple } define-primitive
\ (tuple) make-flushable

: (array) ( n -- array ) missing-intrinsic ;

\ (array) { integer } { array } define-primitive
\ (array) make-flushable

: (byte-array) ( n -- byte-array ) missing-intrinsic ;

\ (byte-array) { integer } { byte-array } define-primitive
\ (byte-array) make-flushable

: (ratio) ( -- ratio ) missing-intrinsic ;

\ (ratio) { } { ratio } define-primitive
\ (ratio) make-flushable

: (complex) ( -- complex ) missing-intrinsic ;

\ (complex) { } { complex } define-primitive
\ (complex) make-flushable

: (wrapper) ( -- wrapper ) missing-intrinsic ;

\ (wrapper) { } { wrapper } define-primitive
\ (wrapper) make-flushable

: (slot) ( obj n tag# -- val ) missing-intrinsic ;

\ (slot) { object fixnum fixnum } { object } define-primitive

: (set-slot) ( val obj n tag# -- ) missing-intrinsic ;

\ (set-slot) { object object fixnum fixnum } { } define-primitive

: (write-barrier) ( obj -- ) missing-intrinsic ;

\ (write-barrier) { object } { } define-primitive
