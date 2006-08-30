! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: serialize
USING: kernel  math hashtables namespaces io strings sequences generic words errors arrays vectors ;

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
GENERIC: (serialize)  ( obj -- )

M: f (serialize) ( obj -- )
	drop "n" write ;

M: fixnum (serialize) ( obj -- )
	! Factor may use 64 bit fixnums on such systems
	"f" write
	4 >be write ;

: bytes-needed ( bignum -- int )
	log2 8 + 8 / floor ;

M: bignum (serialize) ( obj -- )
	"b" write
	dup bytes-needed (serialize)
	dup bytes-needed >be write ;

M: float (serialize) ( obj -- )
	"F" write
	float>bits (serialize) ;

M: complex (serialize) ( obj -- )
	"c" write
	dup real (serialize)
	imaginary (serialize) ;

M: ratio (serialize) ( obj -- )
	"r" write
	dup numerator (serialize)
	denominator (serialize) ;

M: string (serialize) ( obj -- )
	"s" write
	dup length (serialize)
	write ;

M: object (serialize) ( obj -- )
	class word-name "Don't know to serialize a " swap append throw ;

M: sbuf (serialize) ( obj -- )
	"S" write 
	dup length (serialize)
	[ (serialize) ] each ;

: (serialize-seq) ( seq code -- )
	over object-id [
          "o" write (serialize) 2drop
        ] [ 
	  write
	  dup add-object (serialize)
	  dup length (serialize)
	  [ (serialize) ] each
        ] if* ;

M: tuple (serialize)
	dup object-id [
	  "o" write (serialize) 2drop
        ] [
	  "t" write 
	  dup add-object (serialize)
	  tuple>array (serialize) 
	] if* ;

M: array (serialize)
	"a" (serialize-seq) ;

M: vector (serialize)
	"v" (serialize-seq) ;

M: hashtable (serialize)
	dup object-id [
	  "o" write (serialize) 2drop
        ] [
	  "h" write
	  dup add-object (serialize)
	  hash>alist (serialize)
	] if* ;

M: word (serialize)
	"w" write
	dup word-name (serialize)
	word-vocabulary (serialize) ;

DEFER: (deserialize)

: deserialize-false ( -- f )
	f ;

: deserialize-fixnum
	4 read be> ;

: deserialize-string
	(deserialize) read ;

: deserialize-ratio
	(deserialize) (deserialize) / ;

: deserialize-complex
	(deserialize) (deserialize) rect> ;

: deserialize-bignum
	(deserialize) read be> ;

: deserialize-word
	(deserialize) dup (deserialize) lookup dup [ nip ] [ "Unknown word" throw ] if ;

: deserialize-array ( -- array )
  (deserialize)     
  [ 
    (deserialize) 
    [ (deserialize) , ] repeat 
  ] { } make 
  [ swap serialized get set-nth ] keep ;

: deserialize-vector ( -- array )
  (deserialize)     
  [ 
    (deserialize) 
    [ (deserialize) , ] repeat 
  ] V{ } make 
  [ swap serialized get set-nth ] keep ;

: deserialize-hashtable ( -- array )
  (deserialize) 
  (deserialize) alist>hash    
  [ swap serialized get set-nth ] keep ;

: deserialize-unknown ( -- object )
  (deserialize) serialized get nth ;

: (deserialize)
	read1 ch>string dup
	H{ { "f" deserialize-fixnum }
           { "s" deserialize-string }
	   { "r" deserialize-ratio }
	   { "c" deserialize-complex }
	   { "b" deserialize-bignum }
	   { "w" deserialize-word }
	   { "n" deserialize-false }
	   { "a" deserialize-array }
	   { "v" deserialize-vector }
	   { "h" deserialize-hashtable }
	   { "o" deserialize-unknown }
	 }
	hash dup [ "Unknown typecode" throw ] unless nip execute ;

: serialize ( obj -- )
  [
    V{ } serialized set
    (serialize) 
  ] with-scope ;

: deserialize ( -- obj )
  [
    V{ } serialized set
    (deserialize)
  ] with-scope ;

PROVIDE: serialize ;