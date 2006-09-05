! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See http://factorcode.org/license.txt for BSD license.
!
IN: serialize
USING: kernel kernel-internals math hashtables namespaces io strings sequences generic words errors arrays vectors ;

! Variable holding a sequence of objects already serialized
SYMBOL: serialized

: add-object ( obj -- id )
  #! Add an object to the sequence of already serialized objects.
  #! Return the id of that object.
  serialized get [ push ] keep length 1 - ;

: object-id ( obj -- id )
  #! Return the id of an already serialized object 
  serialized get [ eq? ] find-with [ drop f ] unless ;

USE: prettyprint 

! Serialize object
GENERIC: serialize  ( obj -- )

: serialize-shared ( obj quot -- )
  >r dup object-id [ "o" write serialize drop ] r> if* ; inline

M: f serialize ( obj -- )
  drop "n" write ;

: bytes-needed ( number -- int )
  log2 8 + 8 /i ;

M: integer serialize ( obj -- )
  dup 0 = [
    drop "z" write
  ] [
    dup 0 < [ neg "m" ] [ "p" ] if write 
    dup bytes-needed dup 4 >be write
    >be write 
  ] if ;

M: float serialize ( obj -- )
  "F" write
  float>bits serialize ;

M: complex serialize ( obj -- )
  [
    "c" write
    dup add-object serialize
    dup real serialize
    imaginary serialize 
  ] serialize-shared ;

M: ratio serialize ( obj -- )
  "r" write
  dup numerator serialize
  denominator serialize ;

M: string serialize ( obj -- )
  [
    "s" write
    dup add-object serialize
    dup length serialize
    write 
  ] serialize-shared ;

M: object serialize ( obj -- )
  class word-name "Don't know to serialize a " swap append throw ;

M: sbuf serialize ( obj -- )
  "S" write 
  dup length serialize
  [ serialize ] each ;

: serialize-seq ( seq code -- )
  swap [ 
    over write
    dup add-object serialize
    dup length serialize
    [ serialize ] each
  ] serialize-shared drop ;

M: tuple serialize ( obj -- )
  [
    "T" write 
    dup add-object serialize
    tuple>array serialize 
  ] serialize-shared ;

M: array serialize ( obj -- )
  "a" serialize-seq ;

M: vector serialize ( obj -- )
  "v" serialize-seq ;

M: quotation serialize ( obj -- )
  "q" serialize-seq ;

M: hashtable serialize ( obj -- )
  [
    "h" write
    dup add-object serialize
    hash>alist serialize
  ] serialize-shared ;

M: word serialize ( obj -- )
  "w" write
  dup word-name serialize
  word-vocabulary serialize ;

M: wrapper serialize ( obj -- )
  "W" write
  wrapped serialize ;

DEFER: deserialize ( -- obj )

: intern-object ( id obj -- )
  swap serialized get set-nth ;

: deserialize-false ( -- f )
  f ;

: deserialize-string ( -- string )
  deserialize deserialize read [ intern-object ] keep ;

: deserialize-ratio ( -- ratio )
  deserialize deserialize / ;

: deserialize-complex ( -- complex )
  deserialize deserialize deserialize rect> [ intern-object ] keep ;

: deserialize-negative-integer ( -- number )
  4 read be> read be> neg ;

: deserialize-positive-integer ( -- number )
  4 read be> read be> ;

: deserialize-zero ( -- number )
  0 ;

: deserialize-float ( -- float )
  deserialize bits>float ;

: deserialize-word ( -- word )
  deserialize dup deserialize lookup dup [ nip ] [ "Unknown word" throw ] if ;

: deserialize-wrapper ( -- wrapper )
  deserialize <wrapper> ;

: deserialize-array ( -- array )
  deserialize     
  [ 
    deserialize 
    [ deserialize , ] repeat 
  ] { } make 
  [ intern-object ] keep ;

: deserialize-vector ( -- array )
  deserialize     
  [ 
    deserialize 
    [ deserialize , ] repeat 
  ] V{ } make 
  [ intern-object ] keep ;

: deserialize-quotation ( -- array )
  deserialize     
  [ 
    deserialize 
    [ deserialize , ] repeat 
  ] [ ] make 
  [ intern-object ] keep ;

: deserialize-hashtable ( -- array )
  deserialize 
  deserialize alist>hash    
  [ intern-object ] keep ;

: deserialize-tuple ( -- array )
  deserialize 
  deserialize array>tuple
  [ intern-object ] keep ;

: deserialize-unknown ( -- object )
  deserialize serialized get nth ;

: deserialize ( -- object )
  read1 ch>string dup
  H{ { "s" deserialize-string }
     { "r" deserialize-ratio }
     { "c" deserialize-complex }
     { "p" deserialize-positive-integer }
     { "m" deserialize-negative-integer }
     { "F" deserialize-float }
     { "w" deserialize-word }
     { "W" deserialize-wrapper }
     { "n" deserialize-false }
     { "a" deserialize-array }
     { "v" deserialize-vector }
     { "q" deserialize-quotation }
     { "h" deserialize-hashtable }
     { "T" deserialize-tuple }
     { "z" deserialize-zero }
     { "o" deserialize-unknown }
  }
  hash dup [ "Unknown typecode" throw ] unless nip execute ;

: with-serialized ( quot -- )
  [ V{ } serialized set call ] with-scope ; inline 

