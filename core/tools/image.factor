! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays bit-arrays byte-arrays errors generic
assocs hashtables assocs hashtables-internals help io kernel kernel-internals
math namespaces parser prettyprint sequences sequences-internals
strings sbufs vectors words modules quotations assocs ;
IN: image

! Constants

: image-magic HEX: 0f0e0d0c ; inline
: image-version 3 ; inline

: char bootstrap-cell 2/ ; inline

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

! Boot quotation, set in boot-stage1.factor
SYMBOL: boot-quot

: emit ( cell -- ) image get push ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) image get push-all ;

: fixup ( value offset -- ) image get set-nth ;

: heap-size ( -- size )
    image get length header-size - bootstrap-cells ;

: here ( -- size ) heap-size data-base + ;

: here-as ( tag -- pointer ) here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

: emit-fixnum ( n -- ) fixnum tag-number tag-address emit ;

: emit-object ( header tag quot -- addr )
    swap here-as >r swap tag-header emit call align-here r> ;
    inline

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

: bignum-radix bignum-bits 2^ 1- ;

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
    bignum tag-number dup [ emit-bignum ] emit-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup most-negative-fixnum most-positive-fixnum between?
    [ fixnum tag-number tag-address ] [ >bignum ' ] if ;

! Floats

M: float '
    float tag-number dup [
        align-here double>bits emit-64
    ] emit-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,OBJECT_TYPE)
    drop object tag-number ;

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
        0 ,
    ] { } make
    \ word tag-number dup [ emit-seq ] emit-object
    swap objects get set-at ;

: word-error ( word msg -- * )
    [ % dup word-vocabulary % " " % word-name % ] "" make throw ;

: transfer-word ( word -- word )
    dup target-word [ ] [ "Missing DEFER: " word-error ] ?if ;

: fixup-word ( word -- offset )
    transfer-word dup objects get at
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] change-each ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped ' wrapper tag-number dup [ emit ] emit-object ;

! Ratios and complexes

: emit-pair
    [ [ emit ] 2apply ] emit-object ;

M: ratio '
    >fraction [ ' ] 2apply ratio tag-number dup emit-pair ;

M: complex '
    >rect [ ' ] 2apply complex tag-number dup emit-pair ;

! Strings

: 16be> 0 [ swap 16 shift bitor ] reduce ;
: 16le> <reversed> 16be> ;

: emit-chars ( seq -- )
    char <groups>
    big-endian get [ [ 16be> ] map ] [ [ 16le> ] map ] if
    emit-seq ;

: pack-string ( string -- newstr )
    dup length 1+ char align 0 pad-right ;

: emit-string ( string -- ptr )
    string type-number object tag-number [
        dup length emit-fixnum
        f ' emit
        pack-string emit-chars
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    objects get [ emit-string ] cache ;

! Byte arrays

: emit-bytes ( seq -- )
    cell <groups>
    big-endian get [ [ be> ] map ] [ [ le> ] map ] if
    emit-seq ;

: pack-bytes ( string -- newstr )
    dup length cell align 0 pad-right ;

: emit-byte-array ( string -- ptr )
    byte-array type-number object tag-number [
        dup length emit-fixnum
        pack-bytes emit-bytes
    ] emit-object ;

M: byte-array '
    objects get [ emit-byte-array ] cache ;

! Bit arrays
: emit-bit-array ( string -- ptr )
    bit-array type-number object tag-number [
        dup length emit-fixnum
        empty? [
            "Cannot serialize non-empty bit array" throw
        ] unless
    ] emit-object ;

M: bit-array '
    objects get [ emit-bit-array ] cache ;

! Arrays and vectors

: emit-array ( list type -- pointer )
    >r [ ' ] map r> object tag-number [
        dup length emit-fixnum
        emit-seq
    ] emit-object ;

: transfer-tuple ( tuple -- tuple )
    tuple>array
    dup first transfer-word 0 pick set-nth
    >tuple ;

M: tuple '
    transfer-tuple
    objects get [
        tuple>array tuple type-number emit-array
    ] cache ;

M: method '
    [
        \ method transfer-word ,
        f ,
        dup method-loc ,
        method-def ,
    ] { } make tuple type-number emit-array ;

M: array '
    array type-number emit-array ;

M: quotation '
    quotation type-number emit-array ;

M: vector '
    dup underlying ' swap length
    vector type-number object tag-number [
        emit-fixnum ! length
        emit ! array ptr
    ] emit-object ;

M: sbuf '
    dup underlying ' swap length
    sbuf type-number object tag-number [
        emit-fixnum ! length
        emit ! array ptr
    ] emit-object ;

! Hashes

M: hashtable '
    [ hash-array ' ] keep
    hashtable type-number object tag-number [
        dup hash-count emit-fixnum
        hash-deleted emit-fixnum
        emit ! array ptr
    ] emit-object ;

! End of the image

: words, ( -- )
    all-words [ emit-word ] each ;

: global, ( -- )
    [
        {
            vocabularies typemap builtins crossref
            articles help-tree changed-words
            modules class<map source-files
        } [ dup get swap bootstrap-word set ] each
    ] H{ } make-assoc '
    global-offset fixup ;

: boot, ( -- ) boot-quot get ' boot-quot-offset fixup ;

: end-image ( -- )
    "Building generic words..." print flush
    all-words [ generic? ] subset [ make-generic ] each
    "Serializing words..." print flush
    words,
    "Serializing global namespace..." print flush
    global,
    "Serializing boot quotation..." print flush
    boot,
    "Performing some word fixups..." print flush
    fixup-words
    heap-size data-heap-size-offset fixup
    "Image length: " write image get length .
    "Object cache size: " write objects get assoc-size .
    \ word global delete-at ;

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
    "resource:/core/bootstrap/profile-"
    swap ".factor" 3append
    run-file ;

: prepare-image ( arch -- )
    bootstrapping? on dup architecture set prepare-profile
    800000 <vector> image set 20000 <hashtable> objects set ;

: make-image ( architecture -- )
    [
        parse-hook off
        prepare-image
        begin-image
        "resource:/core/bootstrap/boot-stage1.factor" run-file
        end-image
        image get image-name write-image
    ] with-scope ;

: make-images ( -- )
    { "x86" "ppc" "amd64" "arm" } [ make-image ] each ;
