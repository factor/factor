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

IN: cross-compiler
USE: combinators
USE: errors
USE: format
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

: lo/hi64 ( long -- hi lo )
    dup
    -32 shift
    HEX: ffffffff bitand
    swap
    HEX: ffffffff bitand ;

: emit64 ( bignum -- )
    lo/hi64 "big-endian" get [ swap ] when emit emit ;

: fixup ( value offset -- ) image set-vector-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ;
: image-version 0 ;

: cell ( we're compiling for a 32-bit system ) 4 ;

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
: vector-type 9 ;
: string-type 10 ;
: sbuf-type   11 ;
: handle-type 12 ;
: bignum-type 13 ;
: float-type  14 ;

: immediate ( x tag -- tagged ) swap tag-bits shift bitor ;
: >header ( id -- tagged ) header-tag immediate ;

( Image header )

: header ( -- )
    image-magic emit
    image-version emit
    ( relocation base at end of header ) 0 emit
    ( bootstrap quotation set later ) 0 emit
    ( global namespace set later ) 0 emit
    ( size of heap set later ) 0 emit ;

: boot-quot-offset 3 ;
: global-offset    4 ;
: heap-size-offset 5 ;
: header-size      6 ;

( Top of heap pointer )

: here ( -- size ) image vector-length header-size - cell * ;
: here-as ( tag -- pointer ) here swap bitor ;
: pad ( -- ) here 8 mod 4 = [ 0 emit ] when ;

( Remember what objects we've compiled )

: pooled-object ( object -- pointer )
    "objects" get hash ;

: pool-object ( object pointer -- )
    swap "objects" get set-hash ;

( Fixnums )

: 'fixnum ( n -- tagged ) fixnum-tag immediate ;

( Floats )

: 'float ( f -- tagged )
    object-tag here-as >r
    float-type >header emit
    0 emit ( alignment -- FIXME 64-bit arch )
    float>bits emit64 r> ;

( Bignums )

: 'bignum ( bignum -- tagged )
    object-tag here-as >r
    bignum-type >header emit
    dup 0 = 1 2 ? emit ( capacity )
    dup 0 < [
        1 emit neg emit
    ] [
        0 emit     emit
    ] ifte r> ;

( Special objects )

! Padded with fixnums for 8-byte alignment

: f, object-tag here-as "f" set f-type >header emit 0 'fixnum emit ;
: t, object-tag here-as "t" set t-type >header emit 0 'fixnum emit ;

:  0,  0 'bignum drop ;
:  1,  1 'bignum drop ;
: -1, -1 'bignum drop ;

( Beginning of the image )
! The image proper begins with the header, then F, T,
! and the bignums 0, 1, and -1.

: begin ( -- ) header f, t, 0, 1, -1, ;

( Words )

: word, ( -- pointer )
    word-tag here-as word-tag >header emit
    0 HEX: fffffff random-int emit ( hashcode )
    0 emit ;

! This is to handle mutually recursive words
! It is a hack. A recursive word in the cdr of a
! cons doesn't work! This never happends though.
!
! Eg : foo [ 5 | foo ] ;

: fixup-word-later ( word -- )
    image vector-length cons "word-fixups" get vector-push ;

: fixup-word ( where word -- )
    dup pooled-object dup [
        nip swap fixup
    ] [
        drop "Not in image: " swap word-name cat2 throw
    ] ifte ;

: fixup-words ( -- )
    "word-fixups" get [ unswons fixup-word ] vector-each ;

: 'word ( word -- pointer )
    dup pooled-object dup [
        nip
    ] [
        drop
        ! Remember where we are, and add the reference later
        dup fixup-word-later
    ] ifte ;

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

: pack ( n n -- )
    "big-endian" get [ swap ] when 16 shift bitor emit ;

: pack-at ( n str -- )
    2dup str-nth rot succ rot str-nth pack ;

: (pack-string) ( n str -- )
    2dup str-length >= [
        2drop
    ] [
        2dup str-length pred = [
            2dup str-nth 0 pack
        ] [
            2dup pack-at
        ] ifte >r 2 + r> (pack-string)
    ] ifte ;

: pack-string ( str -- ) 0 swap (pack-string) ;

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

IN: namespaces

: namespace-buckets 23 ;

IN: cross-compiler

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
    [,

    dup word-name "name" swons ,
    dup word-vocabulary "vocabulary" swons ,
    "parsing" over word-property [ t "parsing" swons , ] when

    drop
    ,] ' ;

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
        [ float?   ] [ 'float       ]
        [ ratio?   ] [ 'ratio       ]
        [ complex? ] [ 'complex     ]
        [ word?    ] [ 'word        ]
        [ cons?    ] [ 'cons        ]
        [ char?    ] [ 'fixnum      ]
        [ string?  ] [ 'string      ]
        [ vector?  ] [ 'vector      ]
        [ t =      ] [ drop "t" get ]
        [ f =      ] [ drop "f" get ]
        [ drop t   ] [ "Cannot cross-compile: " swap cat2 throw ]
    ] cond ;

( End of the image )

: (set-boot) ( quot -- ) ' boot-quot-offset fixup ;
: (set-global) ( namespace -- ) ' global-offset fixup ;

: global, ( -- )
    "vocabularies" get "vocabularies"
    namespace-buckets <hashtable>
    dup >r set-hash r> (set-global) ;

: end ( -- ) global, fixup-words here heap-size-offset fixup ;

( Image output )

: write-word ( word -- )
    "big-endian" get [
        write-big-endian-32
    ] [
        write-little-endian-32
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
