! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

IN: image
USE: errors
USE: generic
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: prettyprint
USE: random
USE: stdio
USE: streams
USE: strings
USE: test
USE: vectors
USE: unparser
USE: words
USE: parser

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Boot quotation, set by boot.factor
SYMBOL: boot-quot

: emit ( cell -- ) image get vector-push ;

: fixup ( value offset -- ) image get set-vector-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ;
: image-version 0 ;

: cell "64-bits" get 8 4 ? ;
: char "64-bits" get 4 2 ? ;

: tag-mask BIN: 111 ; inline
: tag-bits 3 ; inline

: untag ( cell tag -- ) tag-mask bitnot bitand ;
: tag ( cell -- tag ) tag-mask bitand ;

: fixnum-tag  BIN: 000 ; inline
: bignum-tag  BIN: 001 ; inline
: cons-tag    BIN: 010 ; inline
: object-tag  BIN: 011 ; inline

: f-type      6  ; inline
: t-type      7  ; inline
: array-type  8  ; inline
: vector-type 11 ; inline
: string-type 12 ; inline
: word-type   17 ; inline

: immediate ( x tag -- tagged ) swap tag-bits shift bitor ;
: >header ( id -- tagged ) object-tag immediate ;

( Image header )

: base
    #! We relocate the image to after the header, and leaving
    #! some empty cells. This lets us differentiate an F pointer
    #! (0/tag 3) from a pointer to the first object in the
    #! image.
    64 cell * ;

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

GENERIC: ' ( obj -- ptr )
#! Write an object to the image.

( Allocator )

: here ( -- size ) 
    image get vector-length header-size - cell * base + ;

: here-as ( tag -- pointer )
    here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

( Remember what objects we've compiled )

: pooled-object ( object -- pointer )
    "objects" get hash ;

: pool-object ( object pointer -- )
    swap "objects" get set-hash ;

( Fixnums )

M: fixnum ' ( n -- tagged ) fixnum-tag immediate ;

( Bignums )

M: bignum ' ( bignum -- tagged )
    #! This can only emit 0, -1 and 1.
    bignum-tag here-as >r
    bignum-tag >header emit
    [
        [[ 0  [ 1 0   ] ]]
        [[ -1 [ 2 1 1 ] ]]
        [[ 1  [ 2 0 1 ] ]]
    ] assoc [ emit ] each align-here r> ;

( Special objects )

! Padded with fixnums for 8-byte alignment

: t,
    object-tag here-as "t" set
    t-type >header emit
    0 ' emit ;

M: t ' ( obj -- ptr ) drop "t" get ;
M: f ' ( obj -- ptr )
    #! f is #define F RETAG(0,OBJECT_TYPE)
    drop object-tag ;

:  0,  0 >bignum ' drop ;
:  1,  1 >bignum ' drop ;
: -1, -1 >bignum ' drop ;

( Beginning of the image )
! The image proper begins with the header, then T,
! and the bignums 0, 1, and -1.

: begin ( -- ) header t, 0, 1, -1, ;

( Words )

: word, ( word -- )
    [
        word-type >header ,
        dup hashcode fixnum-tag immediate ,
        0 ,
        dup word-primitive ,
        dup word-parameter ' ,
        dup word-plist ' ,
        0 ,
        0 ,
    ] make-list
    swap object-tag here-as pool-object
    [ emit ] each ;

: word-error ( word msg -- )
    [
        ,
        dup word-vocabulary ,
        " " ,
        word-name ,
    ] make-string throw ;

: transfer-word ( word -- word )
    #! This is a hack. See doc/bootstrap.txt.
    dup dup word-name swap word-vocabulary unit search
    [ dup "Missing DEFER: " word-error ] ?unless ;

: fixup-word ( word -- offset )
    dup pooled-object [ "Not in image: " word-error ] ?unless ;

: fixup-words ( -- )
    image get [
        dup word? [ fixup-word ] when
    ] vector-map image set ;

M: word ' ( word -- pointer )
    transfer-word dup pooled-object dup [ nip ] [ drop ] ifte ;

( Conses )

M: cons ' ( c -- tagged )
    uncons ' swap '
    cons-tag here-as
    -rot emit emit ;

( Strings )

: align-string ( n str -- )
    tuck str-length - CHAR: \0 fill cat2 ;

: emit-chars ( str -- )
    "big-endian" get [ str-reverse ] unless
    0 swap [ swap 16 shift + ] str-each emit ;

: (pack-string) ( n list -- )
    #! Emit bytes for a string, with n characters per word.
    [
        2dup str-length > [ dupd align-string ] when  emit-chars
    ] each drop ;

: pack-string ( string -- )
    char tuck swap split-n (pack-string) ;

: emit-string ( string -- )
    object-tag here-as swap
    string-type >header emit
    dup str-length emit
    dup hashcode fixnum-tag immediate emit
    pack-string
    align-here ;

M: string ' ( string -- pointer )
    #! We pool strings so that each string is only written once
    #! to the image
    dup pooled-object [
        dup emit-string dup >r pool-object r>
    ] ?unless ;

( Arrays and vectors )

: emit-array ( list -- pointer )
    [ ' ] map
    object-tag here-as >r
    array-type >header emit
    dup length emit
    ( elements -- ) [ emit ] each
    align-here r> ;

: emit-vector ( vector -- pointer )
    dup vector>list emit-array swap vector-length
    object-tag here-as >r
    vector-type >header emit
    emit ( length )
    emit ( array ptr )
    align-here r> ;

M: vector ' ( vector -- pointer )
    emit-vector ;

: rehash ( hashtable -- )
    ! Now make a rehashing boot quotation
    dup hash>alist [
        >r dup vector-length [
            [ f swap pick set-vector-nth ] keep
        ] repeat r>
        [ unswons rot set-hash ] each-with
    ] cons cons
    boot-quot [ append ] change ;

M: hashtable ' ( hashtable -- pointer )
    #! Only hashtables are pooled, not vectors!
    dup pooled-object [
        [ dup emit-vector [ pool-object ] keep ] keep rehash
    ] ?unless ;

( End of the image )

: vocabularies, ( vocabularies -- )
    [
        cdr dup vector? [
            [
                cdr dup word? [ word, ] [ drop ] ifte
            ] hash-each
        ] [
            drop
        ] ifte
    ] hash-each ;

: global, ( -- )
    vocabularies get
    dup vocabularies,
    <namespace> [ vocabularies set ] extend '
    global-offset fixup ;

: boot, ( quot -- )
    boot-quot get swap append ' boot-quot-offset fixup ;

: end ( quot -- )
    global,
    boot,
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
        300000 <vector> image set
        521 <hashtable> "objects" set
        ! Note that this is a vector that we can side-effect,
        ! since ; ends up using this variable from nested
        ! parser namespaces.
        1000 <vector> "word-fixups" set
        call
        image get
    ] with-scope ;

: with-image ( quot -- image )
    #! The quotation leaves a boot quotation on the stack.
    [ begin call end ] with-minimal-image ;

: test-image ( quot -- ) with-image vector>list . ;

: make-image ( name -- )
    #! Make an image for the C interpreter.
    [
        boot-quot off
        "/library/bootstrap/boot.factor" run-resource
    ] with-image

    swap write-image ;

: make-images ( -- )
    "64-bits" off
    "big-endian" off "boot.image.le32" make-image
    "big-endian" on  "boot.image.be32" make-image
    "64-bits" on
    "big-endian" off "boot.image.le64" make-image
    "big-endian" on  "boot.image.be64" make-image
    "64-bits" off ;
