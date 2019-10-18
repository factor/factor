! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
SYMBOL: c-types

USING: arrays errors generic hashtables hashtables-internals
help io kernel kernel-internals math namespaces parser
prettyprint sequences sequences-internals strings vectors words
modules ;
IN: image

! Constants

: image-magic HEX: 0f0e0d0c ; inline
: image-version 2 ; inline

: char bootstrap-cell 2 /i ; inline

: untag ( cell -- cell ) tag-mask bitnot bitand ; inline
: tag ( cell -- tag ) tag-mask bitand ; inline

: array-type      8  ; inline
: hashtable-type  10 ; inline
: vector-type     11 ; inline
: string-type     12 ; inline
: sbuf-type       13 ; inline
: quotation-type  14 ; inline
: dll-type        15 ; inline
: alien-type      16 ; inline
: tuple-type      17 ; inline
: byte-array-type 18 ; inline

: data-base 1024 ; inline

: boot-quot-offset      3 ; inline
: global-offset         4 ; inline
: t-offset              5 ; inline
: 0-offset              6 ; inline
: 1-offset              7 ; inline
: -1-offset             8 ; inline
: data-heap-size-offset 9 ; inline
: code-heap-size-offset 10 ; inline

: header-size 12 ; inline

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Object cache
SYMBOL: objects

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

: emit ( cell -- ) image get push ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) image get swap nappend ;

: fixup ( value offset -- ) image get set-nth ;

: here ( -- size ) 
    image get length header-size - bootstrap-cells data-base + ;

: here-as ( tag -- pointer ) here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

: emit-fixnum ( n -- ) fixnum-tag tag-address emit ;

: emit-object ( header tag quot -- addr )
    swap here-as >r swap tag-header emit call align-here r> ;

! Image header

: header ( -- )
    image-magic emit
    image-version emit
     data-base emit ! relocation base at end of header
     0 emit ! bootstrap quotation set later
     0 emit ! global namespace set later
     0 emit ! pointer to t object
     0 emit ! pointer to bignum 0
     0 emit ! pointer to bignum 1
     0 emit ! pointer to bignum -1
     0 emit ! size of data heap set later
     0 emit ! size of code heap is 0
     0 emit ; ! reloc base of code heap is 0

GENERIC: ' ( obj -- ptr )
#! Write an object to the image.

! Bignums

: bignum-bits bootstrap-cell-bits 2 - ;

: bignum-radix bignum-bits 1 swap shift 1- ;

: (bignum>seq) ( n -- )
    dup zero? [
        drop
    ] [
        dup bignum-radix bitand ,
        bignum-bits neg shift (bignum>seq)
    ] if ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ (bignum>seq) ] { } make ;

: emit-bignum ( n -- )
    [ 0 < 1 0 ? ] keep abs bignum>seq
    dup length 1+ emit-fixnum
    swap emit emit-seq ;

M: bignum '
    #! This can only emit 0, -1 and 1.
    bignum-tag bignum-tag [ emit-bignum ] emit-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup most-negative-fixnum most-positive-fixnum between?
    [ fixnum-tag tag-address ] [ >bignum ' ] if ;

! Floats

M: float '
    float-tag float-tag [
        align-here double>bits emit-64
    ] emit-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,OBJECT_TYPE)
    drop object-tag ;

:  0,  0 >bignum '  0-offset fixup ;
:  1,  1 >bignum '  1-offset fixup ;
: -1, -1 >bignum ' -1-offset fixup ;

! Beginning of the image
! The image begins with the header, then T,
! and the bignums 0, 1, and -1.

: begin-image ( -- ) header t, 0, 1, -1, ;

! Words

: emit-word ( word -- )
    [
        dup hashcode ' ,
        dup word-name ' ,
        dup word-vocabulary ' ,
        dup word-primitive ' ,
        dup word-def ' ,
        dup word-props ' ,
        f ' ,
        0 ,
    ] { } make
    word-tag word-tag [ emit-seq ] emit-object
    swap objects get set-hash ;

: word-error ( word msg -- * )
    [ % dup word-vocabulary % " " % word-name % ] "" make throw ;

: transfer-word ( word -- word )
    dup target-word [ ] [ "Missing DEFER: " word-error ] ?if ;

: fixup-word ( word -- offset )
    transfer-word dup objects get hash
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] inject ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped ' wrapper-tag wrapper-tag [ emit ] emit-object ;

! Ratios and complexes

: emit-pair
    [ [ emit ] 2apply ] emit-object ;

M: ratio '
    >fraction [ ' ] 2apply ratio-tag ratio-tag emit-pair ;

M: complex '
    >rect [ ' ] 2apply complex-tag complex-tag emit-pair ;

! Strings

: emit-chars ( seq -- )
    big-endian get [ [ <reversed> ] map ] unless
    [ 0 [ swap 16 shift + ] reduce emit ] each ;

: pack-string ( string -- seq )
    dup length 1+ char align CHAR: \0 pad-right char group ;

: emit-string ( string -- ptr )
    string-type object-tag [
        dup length emit-fixnum
        dup hashcode emit-fixnum
        pack-string emit-chars
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    objects get [ emit-string ] cache ;

! Arrays and vectors

: emit-array ( list type -- pointer )
    >r [ ' ] map r> object-tag [
        dup length emit-fixnum
        ( elements -- ) emit-seq
    ] emit-object ;

: transfer-tuple ( tuple -- tuple )
    tuple>array
    dup first transfer-word 0 pick set-nth
    >tuple ;

M: tuple '
    transfer-tuple
    objects get [ tuple>array tuple-type emit-array ] cache ;

M: array '
    array-type emit-array ;

M: quotation '
    quotation-type emit-array ;

M: vector '
    dup underlying ' swap length
    vector-type object-tag [
        emit-fixnum ( length )
        emit ( array ptr )
    ] emit-object ;

M: sbuf '
    dup underlying ' swap length
    sbuf-type object-tag [
        emit-fixnum ( length )
        emit ( array ptr )
    ] emit-object ;

! Hashes

M: hashtable '
    [ hash-array ' ] keep
    hashtable-type object-tag [
        dup hash-count emit-fixnum
        hash-deleted emit-fixnum
        emit ( array ptr )
    ] emit-object ;

! End of the image

: words, ( -- )
    all-words [ emit-word ] each ;

: global, ( -- )
    [
        {
            vocabularies typemap builtins c-types crossref
            articles parent-graph term-index changed-words
            modules class<map source-files
        } [ dup get swap bootstrap-word set ] each
    ] make-hash '
    global-offset fixup ;

: boot, ( quot -- ) ' boot-quot-offset fixup ;

: heap-size image get length header-size - bootstrap-cells ;

: end-image ( quot -- )
    "Generating words..." print flush
    words,
    "Generating global namespace..." print flush
    global,
    "Generating boot quotation..." print flush
    boot,
    "Performing some word fixups..." print flush
    fixup-words
    heap-size data-heap-size-offset fixup
    "Image length: " write image get length .
    "Object cache size: " write objects get hash-size .
    \ word global remove-hash ;

! Image output

: (write-image) ( image -- )
    bootstrap-cell swap big-endian get [
        [ swap >be write ] each-with
    ] [
        [ swap >le write ] each-with
    ] if ;

: image-name
    "boot.image." architecture get append resource-path ;

: write-image ( image -- )
    "Writing image to " write dup write "..." print flush
    <file-writer> [ (write-image) ] with-stream ;

: prepare-profile ( arch -- )
    "resource:/library/bootstrap/profile-"
    swap ".factor" append3
    run-file ;

: prepare-image ( arch -- )
    bootstrapping? on dup architecture set prepare-profile
    800000 <vector> image set 20000 <hashtable> objects set ;

: make-image ( architecture -- )
    [
        parse-hook off
        prepare-image
        begin-image
        "resource:/library/bootstrap/boot-stage1.factor" run-file
        end-image
        image get image-name write-image
    ] with-scope ;

: make-images ( -- )
    { "x86" "pentium4" "ppc" "amd64" } [ make-image ] each ;
