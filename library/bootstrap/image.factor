! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

! This library allows one to generate a new set of bootstrap
! images (boot.image.{le32,le64,be32,be64}.
!
! It does this by parsing the set of source files needed to
! generate the minimal image, and writing the cons cells, words,
! strings etc to the image file in the CFactor object memory
! format.
!
! What is a bootstrap image? It basically contains enough code
! to parse a source file. See platform/native/boot.factor --
! It initializes the core interpreter services, and proceeds to
! run platform/native/boot-stage2.factor.

IN: namespaces

( Java Factor doesn't have this )
: namespace-buckets 23 ;

IN: image
USE: combinators
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: prettyprint
USE: random
USE: stack
USE: stdio
USE: streams
USE: strings
USE: test
USE: vectors
USE: unparser
USE: words

: image "image" get ;
: emit ( cell -- ) image vector-push ;

: fixup ( value offset -- ) image set-vector-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ;
: image-version 0 ;

: cell "64-bits" get 8 4 ? ;
: char "64-bits" get 4 2 ? ;

: tag-mask BIN: 111 ;
: tag-bits 3 ;

: untag ( cell tag -- ) tag-mask bitnot bitand ;
: tag ( cell -- tag ) tag-mask bitand ;

: fixnum-tag  BIN: 000 ;
: word-tag    BIN: 001 ;
: cons-tag    BIN: 010 ;
: object-tag  BIN: 011 ;
: ratio-tag   BIN: 100 ;
: complex-tag BIN: 101 ;
: header-tag  BIN: 110 ;
: gc-fwd-ptr  BIN: 111 ; ( we don't output these )

: f-type      6 ;
: t-type      7 ;
: array-type  8 ;
: bignum-type 9 ;
: float-type  10 ;
: vector-type 11 ;
: string-type 12 ;

: immediate ( x tag -- tagged ) swap tag-bits shift bitor ;
: >header ( id -- tagged ) header-tag immediate ;

( Image header )

: base
    #! We relocate the image to after the header, and leaving
    #! two empty cells. This lets us differentiate an F pointer
    #! (0/tag 3) from a pointer to the first object in the
    #! image.
    2 cell * ;

: header ( -- )
    image-magic emit
    image-version emit
    ( relocation base at end of header ) base emit
    ( bootstrap quotation set later ) 0 emit
    ( global namespace set later ) 0 emit
    ( size of heap set later ) 0 emit ;

: boot-quot-offset 3 ;
: global-offset    4 ;
: heap-size-offset 5 ;
: header-size      6 ;

( Allocator )

: here ( -- size ) 
    image vector-length header-size - cell * base + ;

: here-as ( tag -- pointer )
    here swap bitor ;

: pad ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

( Remember what objects we've compiled )

: pooled-object ( object -- pointer )
    "objects" get hash ;

: pool-object ( object pointer -- )
    swap "objects" get set-hash ;

( Fixnums )

: 'fixnum ( n -- tagged ) fixnum-tag immediate ;

( Bignums )

: 'bignum ( bignum -- tagged )
    object-tag here-as >r
    bignum-type >header emit
    dup 0 = 1 2 ? emit ( capacity )
    [
        [ 0 = ] [ emit pad ]
        [ 0 < ] [ 1 emit neg emit ]
        [ 0 > ] [ 0 emit     emit ]
    ] cond r> ;

( Special objects )

! Padded with fixnums for 8-byte alignment

: t,
    object-tag here-as "t" set
    t-type >header emit
    0 'fixnum emit ;

:  0,  0 'bignum drop ;
:  1,  1 'bignum drop ;
: -1, -1 'bignum drop ;

( Beginning of the image )
! The image proper begins with the header, then T,
! and the bignums 0, 1, and -1.

: begin ( -- ) header t, 0, 1, -1, ;

( Words )

: word, ( -- pointer )
    word-tag here-as word-tag >header emit
    0 HEX: fffffff random-int emit ( hashcode )
    0 emit ;

! This is to handle mutually recursive words

: fixup-word ( word -- offset )
    dup pooled-object dup [
        nip
    ] [
        drop "Not in image: " swap word-name cat2 throw
    ] ifte ;

: fixup-words ( -- )
    "image" get [
        dup word? [ fixup-word ] when
    ] vector-map "image" set ;

: 'word ( word -- pointer )
    dup pooled-object dup [ nip ] [ drop ] ifte ;

( Conses )

DEFER: '

: cons, ( -- pointer ) cons-tag here-as ;
: 'cons ( c -- tagged ) uncons ' swap ' cons, -rot emit emit ;

( Ratios -- almost the same as a cons )

: ratio, ( -- pointer ) ratio-tag here-as ;
: 'ratio ( a/b -- tagged )
    dup denominator ' swap numerator ' ratio, -rot emit emit ;

( Complex -- almost the same as ratio )

: complex, ( -- pointer ) complex-tag here-as ;
: 'complex ( #{ a b } -- tagged )
    dup imaginary ' swap real ' complex, -rot emit emit ;

( Strings )

: align-string ( n str -- )
    tuck str-length - CHAR: \0 fill cat2 ;

: emit-string ( str -- )
    "big-endian" get [ str-reverse ] unless
    0 swap [ swap 16 shift + ] str-each emit ;

: (pack-string) ( n list -- )
    #! Emit bytes for a string, with n characters per word.
    [
        2dup str-length > [ dupd align-string ] when
        emit-string
    ] each drop ;

: pack-string ( string -- )
    char tuck swap split-n (pack-string) ;

: string, ( string -- )
    object-tag here-as swap
    string-type >header emit
    dup str-length emit
    dup hashcode emit
    pack-string
    pad ;

: 'string ( string -- pointer )
    #! We pool strings so that each string is only written once
    #! to the image
    dup pooled-object dup [
        nip
    ] [
        drop dup string, dup >r pool-object r>
    ] ifte ;

( Word definitions )

: (vocabulary) ( name -- vocab )
    #! Vocabulary for target image.
    dup "vocabularies" get hash dup [
        nip
    ] [
        drop >r namespace-buckets <hashtable> dup r>
        "vocabularies" get set-hash
    ] ifte ;

: (word+) ( word -- )
    #! Add the word to a vocabulary in the target image.
    dup word-name over word-vocabulary 
    (vocabulary) set-hash ;

: 'plist ( word -- plist )
    [
        dup word-name "name" swons ,
        dup word-vocabulary "vocabulary" swons ,
        "parsing" word-property [ t "parsing" swons , ] when
    ] make-list ' ;

: (worddef,) ( word primitive parameter -- )
    ' >r >r dup (word+) dup 'plist >r
    word, pool-object
    r> ( -- plist )
    r> ( primitive -- ) emit
    r> ( parameter -- ) emit
    ( plist -- ) emit
    0 emit ( padding )
    0 emit ;

: primitive, ( word primitive -- ) f (worddef,) ;
: compound, ( word definition -- ) 1 swap (worddef,) ;

( Arrays and vectors )

: 'array ( list -- untagged )
    [ ' ] map
    here >r
    array-type >header emit
    dup length emit
    ( elements -- ) [ emit ] each
    pad r> ;

: 'vector ( vector -- pointer )
    dup vector>list 'array swap vector-length
    object-tag here-as >r
    vector-type >header emit
    emit ( length )
    emit ( array ptr )
    pad r> ;

( Cross-compile a reference to an object )

: ' ( obj -- pointer )
    [
        [ fixnum?  ] [ 'fixnum      ]
        [ bignum?  ] [ 'bignum      ]
        [ ratio?   ] [ 'ratio       ]
        [ complex? ] [ 'complex     ]
        [ word?    ] [ 'word        ]
        [ cons?    ] [ 'cons        ]
        [ string?  ] [ 'string      ]
        [ vector?  ] [ 'vector      ]
        [ t =      ] [ drop "t" get ]
        ! f is #define F RETAG(0,OBJECT_TYPE)
        [ f =      ] [ drop object-tag ]
        [ drop t   ] [ "Cannot cross-compile: " swap cat2 throw ]
    ] cond ;

( End of the image )

: (set-boot) ( quot -- ) ' boot-quot-offset fixup ;
: (set-global) ( namespace -- ) ' global-offset fixup ;

: global, ( -- )
    "vocabularies" get "vocabularies"
    namespace-buckets <hashtable>
    dup >r set-hash r> (set-global) ;

: end ( -- )
    global,
    fixup-words
    here base - heap-size-offset fixup ;

( Image output )

: write-word ( word -- )
    "64-bits" get [
        "big-endian" get [
            write-big-endian-64
        ] [
            write-little-endian-64
        ] ifte
    ] [
         "big-endian" get [
            write-big-endian-32
        ] [
            write-little-endian-32
        ] ifte
    ] ifte ;

: write-image ( image file -- )
    <filebw> [ [ write-word ] vector-each ] with-stream ;

: with-minimal-image ( quot -- image )
    [
        300000 <vector> "image" set
        521 <hashtable> "objects" set
        namespace-buckets <hashtable> "vocabularies" set
        ! Note that this is a vector that we can side-effect,
        ! since ; ends up using this variable from nested
        ! parser namespaces.
        1000 <vector> "word-fixups" set
        call
        "image" get
    ] with-scope ;

: with-image ( quot -- image )
    [ begin call end ] with-minimal-image ;

: test-image ( quot -- ) with-image vector>list . ;
