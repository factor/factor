! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

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
USING: errors generic hashtables kernel lists
math namespaces parser prettyprint sequences sequences stdio
streams strings vectors words ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Boot quotation, set by boot.factor
SYMBOL: boot-quot

: emit ( cell -- ) image get push ;

: fixup ( value offset -- ) image get set-nth ;

( Object memory )

: image-magic HEX: 0f0e0d0c ;
: image-version 0 ;

: cell "64-bits" get 8 4 ? ;
: char "64-bits" get 4 2 ? ;

: untag ( cell tag -- ) tag-mask bitnot bitand ;
: tag ( cell -- tag ) tag-mask bitand ;

: t-type         7  ; inline
: array-type     8  ; inline
: hashtable-type 10 ; inline
: vector-type    11 ; inline
: string-type    12 ; inline
: word-type      17 ; inline

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
    image get length header-size - cell * base + ;

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

: emit-fixnum ( n -- ) fixnum-tag immediate emit ;

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
    ] assoc unswons emit-fixnum [ emit ] each align-here r> ;

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
! The image begins with the header, then T,
! and the bignums 0, 1, and -1.

: begin ( -- ) header t, 0, 1, -1, ;

( Words )

: word, ( word -- )
    [
        word-type >header ,
        dup hashcode fixnum-tag immediate ,
        0 ,
        dup word-primitive ,
        dup word-def ' ,
        dup word-props ' ,
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
    [ ] [ dup "Missing DEFER: " word-error ] ?ifte ;

: fixup-word ( word -- offset )
    dup pooled-object [ ] [ "Not in image: " word-error ] ?ifte ;

: fixup-words ( -- )
    image get [
        dup word? [ fixup-word ] when
    ] seq-map image set ;

M: word ' ( word -- pointer )
    transfer-word dup pooled-object dup [ nip ] [ drop ] ifte ;

( Conses )

M: cons ' ( c -- tagged )
    uncons ' swap '
    cons-tag here-as
    -rot emit emit ;

( Strings )

: align-string ( n str -- )
    tuck length - CHAR: \0 fill cat2 ;

: emit-chars ( str -- )
    >list "big-endian" get [ reverse ] unless
    0 swap [ swap 16 shift + ] each emit ;

: (pack-string) ( n list -- )
    #! Emit bytes for a string, with n characters per word.
    [
        2dup length > [ dupd align-string ] when
        emit-chars
    ] each drop ;

: pack-string ( string -- )
    char tuck swap split-n (pack-string) ;

: emit-string ( string -- )
    object-tag here-as swap
    string-type >header emit
    dup length emit-fixnum
    dup hashcode emit-fixnum
    "\0" cat2 pack-string
    align-here ;

M: string ' ( string -- pointer )
    #! We pool strings so that each string is only written once
    #! to the image
    dup pooled-object [ ] [
        dup emit-string dup >r pool-object r>
    ] ?ifte ;

( Arrays and vectors )

: emit-array ( list -- pointer )
    [ ' ] map
    object-tag here-as >r
    array-type >header emit
    dup length emit-fixnum
    ( elements -- ) [ emit ] each
    align-here r> ;

: emit-vector ( vector -- pointer )
    dup >list emit-array swap length
    object-tag here-as >r
    vector-type >header emit
    emit-fixnum ( length )
    emit ( array ptr )
    align-here r> ;

M: vector ' ( vector -- pointer )
    emit-vector ;

: emit-hashtable ( hash -- pointer )
    dup buckets>list emit-array swap hash>alist length
    object-tag here-as >r
    hashtable-type >header emit
    emit-fixnum ( length )
    emit ( array ptr )
    align-here r> ;

M: hashtable ' ( hashtable -- pointer )
    #! Only hashtables are pooled, not vectors!
    dup pooled-object [ ] [
        dup emit-hashtable [ pool-object ] keep
    ] ?ifte ;

( End of the image )

: vocabularies, ( vocabularies -- )
    [
        cdr dup hashtable? [
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
    <namespace> [
        vocabularies set
        typemap [ ] change
        builtins [ ] change
    ] extend '
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
    <file-writer> [ [ write-word ] seq-each ] with-stream ;

: with-minimal-image ( quot -- image )
    [
        300000 <vector> image set
        <namespace> "objects" set
        call
        image get
    ] with-scope ;

: with-image ( quot -- image )
    #! The quotation leaves a boot quotation on the stack.
    [ begin call end ] with-minimal-image ;

: test-image ( quot -- ) with-image >list . ;

: make-image ( name -- )
    #! Make an image for the C interpreter.
    [
        boot-quot off
        "/library/bootstrap/boot-stage1.factor" run-resource
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
