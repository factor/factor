IN: serialise
USING: kernel generic strings lists vectors arrays sequences math
       io words errors hashtables prettyprint memory namespaces ;

! Variable holding a hashtable of object addresses already serialised
SYMBOL: serialised

: serialised-address ( obj -- number|f )
  #! Return the address of the object if it has already been serialised
  #! otherwise false if it has not been serialised.
  address serialised get hash ;

: mark-serialised ( obj -- )
  #! Set the fact that this object has been serialised
  address dup serialised get set-hash ;

USE: prettyprint 
: get-serialised-object ( id -- obj )
  #! Return the object with the given id for a previously
  #! serialised object.
  serialised get hash ;

: set-serialised-object ( object id -- )
  #! Associate the id with the given object for deserialisation.
  serialised get set-hash ;

! Serialise object
GENERIC: (serialise)  ( obj -- )

M: f (serialise) ( obj -- )
	drop "n" write ;

M: fixnum (serialise) ( obj -- )
	! Factor may use 64 bit fixnums on such systems
	"f" write
	4 >be write ;

: bytes-needed ( bignum -- int )
	log2 8 + 8 / floor ;

M: bignum (serialise) ( obj -- )
	"b" write
	dup bytes-needed (serialise)
	dup bytes-needed >be write ;

M: float (serialise) ( obj -- )
	"F" write
	float>bits (serialise) ;

M: complex (serialise) ( obj -- )
	"c" write
	dup real (serialise)
	imaginary (serialise) ;

M: ratio (serialise) ( obj -- )
	"r" write
	dup numerator (serialise)
	denominator (serialise) ;

M: string (serialise) ( obj -- )
	"s" write
	dup length (serialise)
	write ;

M: object (serialise) ( obj -- )
	class word-name "Don't know to serialise a " swap append throw ;

M: sbuf (serialise) ( obj -- )
	"S" write 
	dup length (serialise)
	[ (serialise) ] each ;

: object-unknown ( obj -- obj was-found-p )
        dup serialised-address [ "o" write (serialise) f ] [ t ] if* ;

: (serialise-seq) ( seq code -- )
	>r object-unknown
	[ 
          r> write
	  dup address (serialise)
	  dup length (serialise)
	  dup mark-serialised
	  [ (serialise) ] each 
        ] [ 
          r> 2drop 
        ] if ;

M: tuple (serialise)
	object-unknown
	[ "t" write tuple>array (serialise) ] [ drop ] if ;

M: array (serialise)
	"a" (serialise-seq) ;

M: vector (serialise)
	"v" (serialise-seq) ;

M: hashtable (serialise)
	"h" 
	>r object-unknown
	[ 
          r> write
	  dup mark-serialised
	  dup address (serialise)
	  dup hash-size (serialise)
	  [ (serialise) (serialise) ] hash-each 
        ] [ 
          r> 2drop 
        ] if ;

M: cons (serialise) ( obj -- )
	object-unknown [ "C" write
        dup mark-serialised
        dup address (serialise)
	dup car (serialise)
	cdr (serialise) ] [ drop ] if ;

M: word (serialise)
	"w" write
	dup word-name (serialise)
	word-vocabulary (serialise) ;

DEFER: (deserialise)

: deserialise-false ( -- f )
	f ;

: deserialise-fixnum
	4 read be> ;

: deserialise-string
	(deserialise) read ;

: deserialise-word
	(deserialise) dup (deserialise) lookup dup [ nip ] [ "Unknown word" throw ] if ;

: deserialise-ratio
	(deserialise) (deserialise) / ;

: deserialise-complex
	(deserialise) (deserialise) rect> ;

: deserialise-bignum
	(deserialise) read be> ;

: deserialise-array ( -- array )
  (deserialise)  
  (deserialise) 
  [ [ (deserialise) , ] repeat ] { } make 
  dup rot set-serialised-object ;

: deserialise-vector ( -- vector )
  (deserialise) ( address ) 
  (deserialise) ( address length )
  [ [ (deserialise) , ] repeat ] V{ } make ( address obj )
  dup rot set-serialised-object ;

: deserialise-hashtable ( -- vector )
  (deserialise) ( address ) 
  (deserialise) ( address length )
  [ [ (deserialise) (deserialise) swap f cons cons , ] repeat ] [ ]  make alist>hash ( address obj )
  dup rot set-serialised-object ;

: deserialise-cons ( -- cons )
  (deserialise) ( address )
  (deserialise) ( address car )
  (deserialise) ( address car cdr )
  cons dup rot set-serialised-object ;

: deserialise-unknown ( -- obj )
  (deserialise) get-serialised-object ;  
  
: serialise ( obj -- )
	[
          8 <hashtable> serialised set
	  (serialise) 
        ] with-scope ;

: (deserialise)
	read1 ch>string dup
	H{ { "f" deserialise-fixnum }
           { "s" deserialise-string }
	   { "r" deserialise-ratio }
	   { "c" deserialise-complex }
	   { "b" deserialise-bignum }
	   { "w" deserialise-word }
	   { "n" deserialise-false }
	   { "a" deserialise-array }
	   { "v" deserialise-vector }
	   { "h" deserialise-hashtable }
	   { "C" deserialise-cons }
	   { "o" deserialise-unknown }
	 }
	hash dup [ "Unknown typecode" throw ] unless nip execute ;

: deserialise ( -- obj )
	[
		8 <hashtable> serialised set (deserialise) 
	] with-scope ;


