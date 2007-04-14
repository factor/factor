! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays bit-arrays byte-arrays generic assocs
hashtables assocs hashtables.private io kernel kernel.private
math namespaces parser prettyprint sequences sequences.private
strings sbufs vectors words quotations assocs system layouts
splitting growable classes tuples tuples.private words.private
io.binary io.files vocabs vocabs.loader source-files
definitions debugger float-arrays quotations.private
sequences.private combinators io.encodings.binary ;
IN: bootstrap.image

: my-arch ( -- arch )
    cpu dup "ppc" = [ os "-" rot 3append ] when ;

: boot-image-name ( arch -- string )
    "boot." swap ".image" 3append ;

: my-boot-image-name ( -- string )
    my-arch boot-image-name ;

: images ( -- seq )
    {
        "x86.32"
        "x86.64"
        "linux-ppc" "macosx-ppc"
        ! "arm"
    } ;

<PRIVATE

! Constants

: image-magic HEX: 0f0e0d0c ; inline
: image-version 4 ; inline

: data-base 1024 ; inline

: userenv-size 64 ; inline

: header-size 10 ; inline

: data-heap-size-offset 3 ; inline
: t-offset              6 ; inline
: 0-offset              7 ; inline
: 1-offset              8 ; inline
: -1-offset             9 ; inline

: array-start 2 bootstrap-cells object tag-number - ;
: scan@ array-start bootstrap-cell - ;
: wrapper@ bootstrap-cell object tag-number - ;
: word-xt@ 8 bootstrap-cells object tag-number - ;
: quot-array@ bootstrap-cell object tag-number - ;
: quot-xt@ 3 bootstrap-cells object tag-number - ;

: jit-define ( quot rc rt offset name -- )
    >r >r >r >r { } make r> r> r> 4array r> set ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Object cache
SYMBOL: objects

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

! Bootstrap global namesapce
SYMBOL: bootstrap-global

! Boot quotation, set in stage1.factor
SYMBOL: bootstrap-boot-quot

! JIT parameters
SYMBOL: jit-code-format
SYMBOL: jit-prolog
SYMBOL: jit-primitive-word
SYMBOL: jit-primitive
SYMBOL: jit-word-jump
SYMBOL: jit-word-call
SYMBOL: jit-push-literal
SYMBOL: jit-if-word
SYMBOL: jit-if-jump
SYMBOL: jit-dispatch-word
SYMBOL: jit-dispatch
SYMBOL: jit-epilog
SYMBOL: jit-return
SYMBOL: jit-profiling

! Default definition for undefined words
SYMBOL: undefined-quot

: userenv-offset ( symbol -- n )
    {
        { bootstrap-boot-quot 20 }
        { bootstrap-global 21 }
        { jit-code-format 22 }
        { jit-prolog 23 }
        { jit-primitive-word 24 }
        { jit-primitive 25 }
        { jit-word-jump 26 }
        { jit-word-call 27 }
        { jit-push-literal 28 }
        { jit-if-word 29 }
        { jit-if-jump 30 }
        { jit-dispatch-word 31 }
        { jit-dispatch 32 }
        { jit-epilog 33 }
        { jit-return 34 }
        { jit-profiling 35 }
        { undefined-quot 37 }
    } at header-size + ;

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
    image get length header-size - userenv-size -
    bootstrap-cells ;

: here ( -- size ) heap-size data-base + ;

: here-as ( tag -- pointer ) here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ heap-size drop 0 emit ] when ;

: emit-fixnum ( n -- ) tag-fixnum emit ;

: emit-object ( header tag quot -- addr )
    swap here-as >r swap tag-fixnum emit call align-here r> ;
    inline

! Write an object to the image.
GENERIC: ' ( obj -- ptr )

! Image header

: emit-header ( -- )
    image-magic emit
    image-version emit
    data-base emit ! relocation base at end of header
    0 emit ! size of data heap set later
    0 emit ! reloc base of code heap is 0
    0 emit ! size of code heap is 0
    0 emit ! pointer to t object
    0 emit ! pointer to bignum 0
    0 emit ! pointer to bignum 1
    0 emit ! pointer to bignum -1
    userenv-size [ f ' emit ] times ;

: emit-userenv ( symbol -- )
    dup get ' swap userenv-offset fixup ;

! Bignums

: bignum-bits bootstrap-cell-bits 2 - ;

: bignum-radix bignum-bits 2^ 1- ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ dup 0 > ]
    [ dup bignum-bits neg shift swap bignum-radix bitand ]
    [ ] unfold nip ;

USE: continuations
: emit-bignum ( n -- )
    dup 0 < [ 1 swap neg ] [ 0 swap ] if bignum>seq
    dup length 1+ emit-fixnum
    swap emit emit-seq ;

M: bignum '
    bignum tag-number dup [ emit-bignum ] emit-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup
    bootstrap-most-negative-fixnum
    bootstrap-most-positive-fixnum between?
    [ tag-fixnum ] [ >bignum ' ] if ;

! Floats

M: float '
    float tag-number dup [
        align-here double>bits emit-64
    ] emit-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,F_TYPE)
    drop \ f tag-number ;

:  0,  0 >bignum '  0-offset fixup ;
:  1,  1 >bignum '  1-offset fixup ;
: -1, -1 >bignum ' -1-offset fixup ;

! Words

: emit-word ( word -- )
    dup subwords [ emit-word ] each
    [
        dup hashcode ' ,
        dup word-name ' ,
        dup word-vocabulary ' ,
        dup word-def ' ,
        dup word-props ' ,
        f ' ,
        0 , ! count
        0 , ! xt
        0 , ! code
        0 , ! profiling
    ] { } make
    \ word type-number object tag-number
    [ emit-seq ] emit-object
    swap objects get set-at ;

: word-error ( word msg -- * )
    [ % dup word-vocabulary % " " % word-name % ] "" make throw ;

: transfer-word ( word -- word )
    dup target-word swap or ;

: fixup-word ( word -- offset )
    transfer-word dup objects get at
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] change-each ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped ' wrapper type-number object tag-number
    [ emit ] emit-object ;

! Strings
: emit-chars ( seq -- )
    bootstrap-cell <groups>
    big-endian get [ [ be> ] map ] [ [ le> ] map ] if
    emit-seq ;

: pack-string ( string -- newstr )
    dup length bootstrap-cell align 0 pad-right ;

: emit-string ( string -- ptr )
    string type-number object tag-number [
        dup length emit-fixnum
        f ' emit
        f ' emit
        pack-string emit-chars
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    objects get [ emit-string ] cache ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    swap assert-empty
    type-number object tag-number
    [ 0 emit-fixnum ] emit-object ;

M: byte-array ' byte-array emit-dummy-array ;

M: bit-array ' bit-array emit-dummy-array ;

M: float-array ' float-array emit-dummy-array ;

! Tuples
: emit-tuple ( tuple -- pointer )
    [
        [
            dup class transfer-word tuple-layout ' ,
            tuple>array 1 tail-slice [ ' ] map %
        ] { } make
        tuple type-number dup [ emit-seq ] emit-object
    ]
    ! Hack
    over class word-name "tombstone" =
    [ objects get swap cache ] [ call ] if ;

M: tuple ' emit-tuple ;

M: tuple-layout '
    objects get [
        [
            dup layout-hashcode ' ,
            dup layout-class ' ,
            dup layout-size ' ,
            dup layout-superclasses ' ,
            layout-echelon ' ,
        ] { } make
        \ tuple-layout type-number
        object tag-number [ emit-seq ] emit-object
    ] cache ;

M: tombstone '
    delegate
    "((tombstone))" "((empty))" ? "hashtables.private" lookup
    word-def first objects get [ emit-tuple ] cache ;

! Arrays
: emit-array ( list type tag -- pointer )
    >r >r [ ' ] map r> r> [
        dup length emit-fixnum
        emit-seq
    ] emit-object ;

M: array '
    array type-number object tag-number emit-array ;

! Quotations

M: quotation '
    objects get [
        quotation-array '
        quotation type-number object tag-number [
            emit ! array
            f ' emit ! compiled?
            0 emit ! xt
            0 emit ! code
        ] emit-object
    ] cache ;

! Curries

M: curry '
    dup curry-quot ' swap curry-obj '
    \ curry type-number object tag-number
    [ emit emit ] emit-object ;

! End of the image

: emit-words ( -- )
    all-words [ emit-word ] each ;

: emit-global ( -- )
    [
        {
            dictionary source-files builtins
            update-map class<-cache class-not-cache
            classes-intersect-cache class-and-cache
            class-or-cache
        } [ dup get swap bootstrap-word set ] each
    ] H{ } make-assoc
    bootstrap-global set
    bootstrap-global emit-userenv ;

: emit-boot-quot ( -- )
    bootstrap-boot-quot emit-userenv ;

: emit-jit-data ( -- )
    \ if jit-if-word set
    \ dispatch jit-dispatch-word set
    \ do-primitive jit-primitive-word set
    [ undefined ] undefined-quot set
    {
        jit-code-format
        jit-prolog
        jit-primitive-word
        jit-primitive
        jit-word-jump
        jit-word-call
        jit-push-literal
        jit-if-word
        jit-if-jump
        jit-dispatch-word
        jit-dispatch
        jit-epilog
        jit-return
        jit-profiling
        undefined-quot
    } [ emit-userenv ] each ;

: fixup-header ( -- )
    heap-size data-heap-size-offset fixup ;

: build-image ( -- image )
    800000 <vector> image set
    20000 <hashtable> objects set
    emit-header t, 0, 1, -1,
    "Serializing words..." print flush
    emit-words
    "Serializing JIT data..." print flush
    emit-jit-data
    "Serializing global namespace..." print flush
    emit-global
    "Serializing boot quotation..." print flush
    emit-boot-quot
    "Performing word fixups..." print flush
    fixup-words
    "Performing header fixups..." print flush
    fixup-header
    "Image length: " write image get length .
    "Object cache size: " write objects get assoc-size .
    \ word global delete-at
    image get ;

! Image output

: (write-image) ( image -- )
    bootstrap-cell big-endian get [
        [ >be write ] curry each
    ] [
        [ >le write ] curry each
    ] if ;

: write-image ( image -- )
    "Writing image to " write
    architecture get boot-image-name resource-path
    dup write "..." print flush
    binary <file-writer> [ (write-image) ] with-stream ;

PRIVATE>

: make-image ( arch -- )
    [
        architecture set
        bootstrapping? on
        load-help? off
        "resource:/core/bootstrap/stage1.factor" run-file
        build-image
        write-image
    ] with-scope ;

: make-images ( -- )
    images [ make-image ] each ;
