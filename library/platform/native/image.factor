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
USE: arithmetic
USE: combinators
USE: errors
USE: format
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: streams
USE: strings
USE: test
USE: vectors
USE: vocabularies
USE: unparser
USE: words

: image "image" get ;
: emit ( cell -- ) image vector-push ;
: fixup ( value offset -- ) image set-vector-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ;
: image-version 0 ;

: cell ( we're compiling for a 32-bit system ) 4 ;

: tag-mask BIN: 111 ;
: tag-bits 3 ;

: untag ( cell tag -- ) tag-mask bitnot bitand ;
: tag ( cell -- tag ) tag-mask bitand ;

: fixnum-tag BIN: 000 ;
: word-tag   BIN: 001 ;
: cons-tag   BIN: 010 ;
: object-tag BIN: 011 ;
: header-tag BIN: 100 ;

: immediate ( x tag -- tagged ) swap tag-bits shift< bitor ;
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

( Special objects )

! Padded with fixnums for 8-byte alignment

: f, object-tag here-as "f" set 6 >header emit 0 'fixnum emit ;
: t, object-tag here-as "t" set 7 >header emit 0 'fixnum emit ;
: empty, 8 >header emit 0 'fixnum emit ;

( Beginning of the image )
! The image proper begins with the header, then EMPTY, F, T

: begin ( -- ) header empty, f, t, ;

( Words )

: word, ( -- pointer )
    word-tag here-as word-tag >header emit 0 emit ;

! This is to handle mutually recursive words
! It is a hack. A recursive word in the cdr of a
! cons doesn't work! This never happends though.
!
! Eg : foo [ 5 | foo ] ;

: fixup-word-later ( word -- )
    image vector-length cons "word-fixups" cons@ ;

: fixup-word ( where word -- )
    dup pooled-object dup [
        nip swap fixup
    ] [
        drop "Not in image: " swap cat2 throw
    ] ifte ;

: fixup-words ( -- )
    "word-fixups" get [ unswons fixup-word ] each ;

: 'word ( word -- pointer )
    dup pooled-object dup [
        nip
    ] [
        drop
        ! Remember where we are, and add the reference later
        fixup-word-later f
    ] ifte ;

( Conses )

DEFER: '

: cons, ( -- pointer ) cons-tag here-as ;
: 'cons ( c -- tagged ) uncons ' swap ' cons, -rot emit emit ;

( Strings )

: pack ( n n -- ) 16 shift< bitor emit ;

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
    11 >header emit
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
    [ "parsing" get >boolean ] bind "parsing" swons ,

    ,] ' ;

: (worddef,) ( word primitive parameter -- )
    ' >r >r dup (word+) dup 'plist >r
    word, pool-object
    r> ( -- plist )
    r> ( primitive -- ) emit
    r> ( parameter -- ) emit
    ( plist -- ) emit
    0 emit ( padding ) ;

: primitive, ( word primitive -- ) f (worddef,) ;
: compound, ( word definition -- ) 1 swap (worddef,) ;

( Arrays and vectors )

: 'array ( list -- untagged )
    [ ' ] inject
    here >r
    9 >header emit
    dup length emit
    ( elements -- ) [ emit ] each
    pad r> ;

: 'vector ( vector -- pointer )
    dup vector>list 'array swap vector-length
    object-tag here-as >r
    10 >header emit
    emit ( length )
    emit ( array ptr )
    pad r> ;

( Cross-compile a reference to an object )

: ' ( obj -- pointer )
    [
        [ fixnum? ] [ 'fixnum      ]
        [ word?   ] [ 'word        ]
        [ cons?   ] [ 'cons        ]
        [ char?   ] [ 'fixnum      ]
        [ string? ] [ 'string      ]
        [ vector? ] [ 'vector      ]
        [ t =     ] [ drop "t" get ]
        [ f =     ] [ drop "f" get ]
        [ drop t  ] [ "Cannot cross-compile: " swap cat2 throw ]
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

: byte0 ( num -- byte ) 24 shift> HEX: ff bitand ;
: byte1 ( num -- byte ) 16 shift> HEX: ff bitand ;
: byte2 ( num -- byte )  8 shift> HEX: ff bitand ;
: byte3 ( num -- byte )           HEX: ff bitand ;

: write-little-endian ( word -- )
    dup byte3 >char write
    dup byte2 >char write
    dup byte1 >char write
        byte0 >char write ;

: write-big-endian ( word -- )
    dup byte0 >char write
    dup byte1 >char write
    dup byte2 >char write
        byte3 >char write ;

: write-word ( word -- )
    "big-endian" get [
        write-big-endian
    ] [
        write-little-endian
    ] ifte ;

: write-image ( image file -- )
    <filebw> [ [ write-word ] vector-each ] with-stream ;

: with-image ( quot -- image )
    <namespace> [
        300000 <vector> "image" set
        521 <hashtable> "objects" set
        namespace-buckets <hashtable> "vocabularies" set
        begin call end
        "image" get
    ] bind ;

: test-image ( quot -- ) with-image vector>list . ;
