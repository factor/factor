! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! This library allows one to generate a new set of bootstrap
! images (boot.image.{le32,le64,be32,be64}.
!
! It does this by parsing the set of source files needed to
! generate the minimal image, and writing the cons cells, words,
! strings etc to the image file in the CFactor object memory
! format.

USING: alien arrays errors generic hashtables
hashtables-internals help io kernel kernel-internals lists math
namespaces parser prettyprint sequences sequences-internals
strings vectors words ;
IN: image

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Object cache
SYMBOL: objects

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

: emit ( cell -- ) image get push ;

: d>w/w ( d -- w w )
    dup HEX: ffffffff bitand swap -32 shift HEX: ffffffff bitand ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) image get swap nappend ;

: fixup ( value offset -- ) image get set-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ; inline
: image-version 0 ; inline

: char bootstrap-cell 2 /i ; inline

: untag ( cell tag -- ) tag-mask bitnot bitand ; inline
: tag ( cell -- tag ) tag-mask bitand ; inline

: array-type     8  ; inline
: hashtable-type 10 ; inline
: vector-type    11 ; inline
: string-type    12 ; inline
: sbuf-type      13 ; inline
: wrapper-type   14 ; inline
: word-type      17 ; inline
: tuple-type     18 ; inline

: immediate ( x tag -- tagged ) swap tag-bits shift bitor ;
: >header ( id -- tagged ) object-tag immediate ;

( Image header )

: base 1024 ;

: header ( -- )
    image-magic emit
    image-version emit
    ( relocation base at end of header ) base emit
    ( bootstrap quotation set later ) 0 emit
    ( global namespace set later ) 0 emit
    ( pointer to t object ) 0 emit
    ( pointer to bignum 0 ) 0 emit
    ( pointer to bignum 1 ) 0 emit
    ( pointer to bignum -1 ) 0 emit
    ( size of heap set later ) 0 emit ;

: boot-quot-offset 3 ;
: global-offset    4 ;
: t-offset         5 ;
: 0-offset         6 ;
: 1-offset         7 ;
: -1-offset        8 ;
: heap-size-offset 9 ;
: header-size      10 ;

GENERIC: ' ( obj -- ptr )
#! Write an object to the image.

( Allocator )

: here ( -- size ) 
    image get length header-size - bootstrap-cells base + ;

: here-as ( tag -- pointer )
    here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

( Fixnums )

: emit-fixnum ( n -- ) fixnum-tag immediate emit ;

M: fixnum ' ( n -- tagged ) fixnum-tag immediate ;

( Bignums )

: bignum-bits cell-bits 2 - ;

: bignum-radix bignum-bits 1 swap shift 1- ;

: (bignum>seq) ( n -- )
    dup 0 = [
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

M: bignum ' ( bignum -- tagged )
    #! This can only emit 0, -1 and 1.
    bignum-tag here-as >r
    bignum-tag >header emit
    emit-bignum align-here r> ;

( Floats )

M: float ' ( float -- tagged )
    float-tag here-as >r
    float-tag >header emit
    align-here
    double>bits emit-64
    r> ;

( Special objects )

! Padded with fixnums for 8-byte alignment

: t, t t-offset fixup ;

M: f ' ( obj -- ptr )
    #! f is #define F RETAG(0,OBJECT_TYPE)
    drop object-tag ;

:  0,  0 >bignum '  0-offset fixup ;
:  1,  1 >bignum '  1-offset fixup ;
: -1, -1 >bignum ' -1-offset fixup ;

( Beginning of the image )
! The image begins with the header, then T,
! and the bignums 0, 1, and -1.

: begin-image ( -- ) header t, 0, 1, -1, ;

( Words )

: emit-word ( word -- )
    dup word-props ' >r
    dup word-def ' >r
    dup word-primitive ' >r
    dup word-vocabulary ' >r
    dup word-name ' >r
    object-tag here-as over objects get set-hash
    word-type >header emit
    hashcode emit-fixnum
    r> emit
    r> emit
    r> emit
    r> emit
    r> emit
    0 emit ;

: word-error ( word msg -- )
    [ % dup word-vocabulary % " " % word-name % ] "" make throw ;

: transfer-word ( word -- word )
    #! This is a hack. See doc/bootstrap.txt.
    dup target-word [ ] [ dup "Missing DEFER: " word-error ] ?if ;

: pooled-object ( object -- ptr ) objects get hash ;

: fixup-word ( word -- offset )
    transfer-word dup pooled-object dup
    [ nip ] [ "Not in image: " word-error ] if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] inject ;

M: word ' ( word -- pointer ) ;

( Wrappers )

M: wrapper ' ( wrapper -- pointer )
    wrapped '
    object-tag here-as >r
    wrapper-type >header emit
    emit r> ;

( Conses )

: emit-cons ( first second tag -- pointer )
    >r ' swap ' r> here-as -rot emit emit ;

M: cons ' ( c -- tagged ) uncons cons-tag emit-cons ;

M: ratio ' ( c -- tagged ) >fraction ratio-tag emit-cons ;

M: complex ' ( c -- tagged ) >rect complex-tag emit-cons ;

( Strings )

: emit-chars ( seq -- )
    big-endian get [ [ reverse-slice ] map ] unless
    [ 0 [ swap 16 shift + ] reduce emit ] each ;

: pack-string ( string -- seq )
    dup length 1+ char align CHAR: \0 pad-right char swap group ;

: emit-string ( string -- ptr )
    object-tag here-as swap
    string-type >header emit
    dup length emit-fixnum
    dup hashcode emit-fixnum
    pack-string emit-chars
    align-here ;

M: string ' ( string -- pointer )
    #! We pool strings so that each string is only written once
    #! to the image
    objects get [ emit-string ] cache ;

( Arrays and vectors )

: emit-array ( list type -- pointer )
    >r [ ' ] map r>
    object-tag here-as >r
    >header emit
    dup length emit-fixnum
    ( elements -- ) emit-seq
    align-here r> ;

: transfer-tuple ( tuple -- tuple )
    tuple>array
    dup first transfer-word 0 pick set-nth
    >tuple ;

M: tuple ' ( tuple -- pointer )
    transfer-tuple
    objects get [ tuple>array tuple-type emit-array ] cache ;

M: array ' ( array -- pointer )
    array-type emit-array ;

M: vector ' ( vector -- pointer )
    dup underlying ' swap length
    object-tag here-as >r
    vector-type >header emit
    emit-fixnum ( length )
    emit ( array ptr )
    align-here r> ;

M: sbuf ' ( sbuf -- pointer )
    dup underlying ' swap length
    object-tag here-as >r
    sbuf-type >header emit
    emit-fixnum ( length )
    emit ( array ptr )
    align-here r> ;

( Hashes )

M: hashtable ' ( hashtable -- pointer )
    [ hash-array ' ] keep
    object-tag here-as >r
    hashtable-type >header emit
    dup hash-count emit-fixnum
    hash-deleted emit-fixnum
    emit ( array ptr )
    align-here r> ;

( End of the image )

: words, ( -- )
    all-words [ emit-word ] each ;

: global, ( -- )
    [
        {
            vocabularies typemap builtins c-types crossref
            articles terms
        }
        [ [ ] change ] each
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
    heap-size heap-size-offset fixup
    "Image length: " write image get length .
    "Object cache size: " write objects get hash-size .
    \ word global remove-hash ;

( Image output )

: (write-image) ( image -- )
    bootstrap-cell swap big-endian get [
        [ swap >be write ] each-with
    ] [
        [ swap >le write ] each-with
    ] if ;

: image-name
    "boot.image." architecture get append ;

: write-image ( image -- )
    "Writing image to " write dup write "..." print flush
    <file-writer> [ (write-image) ] with-stream ;

: prepare-profile ( arch -- )
    "/library/bootstrap/profile-" swap ".factor" append3
    run-resource ;

: prepare-image ( arch -- )
    bootstrapping? on dup architecture set prepare-profile
    800000 <vector> image set 20000 <hashtable> objects set ;

: make-image ( architecture -- )
    #! Make a bootstrap image for the given architecture
    #! (x86, ppc, or amd64).
    [
        prepare-image
        begin-image
        "/library/bootstrap/boot-stage1.factor" run-resource
        end-image
        image get image-name write-image
    ] with-scope ;

: make-images ( -- )
    "x86" make-image "ppc" make-image "amd64" make-image ;
