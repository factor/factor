! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic hashtables
hashtables.private io io.binary io.files io.encodings.binary
io.pathnames kernel kernel.private math namespaces make parser
prettyprint sequences strings sbufs vectors words quotations
assocs system layouts splitting grouping growable classes
classes.builtin classes.tuple classes.tuple.private vocabs
vocabs.loader source-files definitions debugger
quotations.private combinators combinators.short-circuit
math.order math.private accessors slots.private
generic.single.private compiler.units compiler.constants fry
bootstrap.image.syntax ;
IN: bootstrap.image

: arch ( os cpu -- arch )
    {
        { "ppc" [ "-ppc" append ] }
        { "x86.64" [ "winnt" = "winnt" "unix" ? "-x86.64" append ] }
        [ nip ]
    } case ;

: my-arch ( -- arch )
    os name>> cpu name>> arch ;

: boot-image-name ( arch -- string )
    "boot." ".image" surround ;

: my-boot-image-name ( -- string )
    my-arch boot-image-name ;

: images ( -- seq )
    {
        "x86.32"
        "winnt-x86.64" "unix-x86.64"
        "linux-ppc" "macosx-ppc"
    } ;

<PRIVATE

! Object cache; we only consider numbers equal if they have the
! same type
TUPLE: eql-wrapper { obj read-only } ;

C: <eql-wrapper> eql-wrapper

M: eql-wrapper hashcode* obj>> hashcode* ;

GENERIC: (eql?) ( obj1 obj2 -- ? )

: eql? ( obj1 obj2 -- ? )
    { [ [ class ] bi@ = ] [ (eql?) ] } 2&& ;

M: fixnum (eql?) eq? ;

M: bignum (eql?) = ;

M: float (eql?) fp-bitwise= ;

M: sequence (eql?) 2dup [ length ] bi@ = [ [ eql? ] 2all? ] [ 2drop f ] if ;

M: object (eql?) = ;

M: eql-wrapper equal?
    over eql-wrapper? [ [ obj>> ] bi@ eql? ] [ 2drop f ] if ;

TUPLE: eq-wrapper { obj read-only } ;

C: <eq-wrapper> eq-wrapper

M: eq-wrapper equal?
    over eq-wrapper? [ [ obj>> ] bi@ eq? ] [ 2drop f ] if ;

SYMBOL: objects

: cache-eql-object ( obj quot -- value )
    [ <eql-wrapper> objects get ] dip '[ obj>> @ ] cache ; inline

: cache-eq-object ( obj quot -- value )
    [ <eq-wrapper> objects get ] dip '[ obj>> @ ] cache ; inline

: lookup-object ( obj -- n/f ) <eq-wrapper> objects get at ;

: put-object ( n obj -- ) <eq-wrapper> objects get set-at ;

! Constants

CONSTANT: image-magic HEX: 0f0e0d0c
CONSTANT: image-version 4

CONSTANT: data-base 1024

CONSTANT: userenv-size 70

CONSTANT: header-size 10

CONSTANT: data-heap-size-offset 3
CONSTANT: t-offset              6
CONSTANT: 0-offset              7
CONSTANT: 1-offset              8
CONSTANT: -1-offset             9

SYMBOL: sub-primitives

SYMBOL: jit-relocations

: compute-offset ( rc -- offset )
    [ building get length ] dip rc-absolute-cell = bootstrap-cell 4 ? - ;

: jit-rel ( rc rt -- )
    over compute-offset 3array jit-relocations get push-all ;

SYMBOL: jit-literals

: jit-literal ( literal -- )
    jit-literals get push ;

: make-jit ( quot -- jit-literals jit-data )
    [
        V{ } clone jit-literals set
        V{ } clone jit-relocations set
        call( -- )
        jit-literals get >array
        jit-relocations get >array
    ] B{ } make prefix ;

: jit-define ( quot name -- )
    [ make-jit nip ] dip set ;

: define-sub-primitive ( quot word -- )
    [ make-jit 2array ] dip sub-primitives get set-at ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

RESET

! Boot quotation, set in stage1.factor
USERENV: bootstrap-boot-quot 20

! Bootstrap global namesapce
USERENV: bootstrap-global 21

! JIT parameters
USERENV: jit-prolog 23
USERENV: jit-primitive-word 24
USERENV: jit-primitive 25
USERENV: jit-word-jump 26
USERENV: jit-word-call 27
USERENV: jit-word-special 28
USERENV: jit-if-word 29
USERENV: jit-if 30
USERENV: jit-epilog 31
USERENV: jit-return 32
USERENV: jit-profiling 33
USERENV: jit-push-immediate 34
USERENV: jit-dip-word 35
USERENV: jit-dip 36
USERENV: jit-2dip-word 37
USERENV: jit-2dip 38
USERENV: jit-3dip-word 39
USERENV: jit-3dip 40
USERENV: jit-execute-word 41
USERENV: jit-execute-jump 42
USERENV: jit-execute-call 43
USERENV: jit-declare-word 44

USERENV: callback-stub 45

! PIC stubs
USERENV: pic-load 47
USERENV: pic-tag 48
USERENV: pic-hi-tag 49
USERENV: pic-tuple 50
USERENV: pic-hi-tag-tuple 51
USERENV: pic-check-tag 52
USERENV: pic-check 53
USERENV: pic-hit 54
USERENV: pic-miss-word 55
USERENV: pic-miss-tail-word 56

! Megamorphic dispatch
USERENV: mega-lookup 57
USERENV: mega-lookup-word 58
USERENV: mega-miss-word 59

! Default definition for undefined words
USERENV: undefined-quot 60

: userenv-offset ( symbol -- n )
    userenvs get at header-size + ;

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

: here-as ( tag -- pointer ) here bitor ;

: (align-here) ( alignment -- )
    [ here neg ] dip rem
    [ bootstrap-cell /i [ 0 emit ] times ] unless-zero ;

: align-here ( -- )
    data-alignment get (align-here) ;

: emit-fixnum ( n -- ) tag-fixnum emit ;

: emit-object ( class quot -- addr )
    over tag-number here-as [ swap type-number tag-fixnum emit call align-here ] dip ;
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
    [ get ' ] [ userenv-offset ] bi fixup ;

! Bignums

: bignum-bits ( -- n ) bootstrap-cell-bits 2 - ;

: bignum-radix ( -- n ) bignum-bits 2^ 1 - ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ dup 0 > ]
    [ [ bignum-bits neg shift ] [ bignum-radix bitand ] bi ]
    produce nip ;

: emit-bignum ( n -- )
    dup dup 0 < [ neg ] when bignum>seq
    [ nip length 1 + emit-fixnum ]
    [ drop 0 < 1 0 ? emit ]
    [ nip emit-seq ]
    2tri ;

M: bignum '
    [
        bignum [ emit-bignum ] emit-object
    ] cache-eql-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup
    bootstrap-most-negative-fixnum
    bootstrap-most-positive-fixnum between?
    [ tag-fixnum ] [ >bignum ' ] if ;

TUPLE: fake-bignum n ;

C: <fake-bignum> fake-bignum

M: fake-bignum ' n>> tag-fixnum ;

! Floats

M: float '
    [
        float [
            8 (align-here) double>bits emit-64
        ] emit-object
    ] cache-eql-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, ( -- ) t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,F_TYPE)
    drop \ f tag-number ;

:  0, ( -- )  0 >bignum '  0-offset fixup ;
:  1, ( -- )  1 >bignum '  1-offset fixup ;
: -1, ( -- ) -1 >bignum ' -1-offset fixup ;

! Words

: word-sub-primitive ( word -- obj )
    global [ target-word ] bind sub-primitives get at ;

: emit-word ( word -- )
    [
        [ subwords [ emit-word ] each ]
        [
            [
                {
                    [ hashcode <fake-bignum> , ]
                    [ name>> , ]
                    [ vocabulary>> , ]
                    [ def>> , ]
                    [ props>> , ]
                    [ pic-def>> , ]
                    [ pic-tail-def>> , ]
                    [ drop 0 , ] ! count
                    [ word-sub-primitive , ]
                    [ drop 0 , ] ! xt
                    [ drop 0 , ] ! code
                    [ drop 0 , ] ! profiling
                } cleave
            ] { } make [ ' ] map
        ] bi
        \ word [ emit-seq ] emit-object
    ] keep put-object ;

: word-error ( word msg -- * )
    [ % dup vocabulary>> % " " % name>> % ] "" make throw ;

: transfer-word ( word -- word )
    [ target-word ] keep or ;

: fixup-word ( word -- offset )
    transfer-word dup lookup-object
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] map! drop ;

M: word ' ;

! Wrappers

M: wrapper '
    [ wrapped>> ' wrapper [ emit ] emit-object ] cache-eql-object ;

! Strings
: native> ( object -- object )
    big-endian get [ [ be> ] map ] [ [ le> ] map ] if ;

: emit-bytes ( seq -- )
    bootstrap-cell <groups> native> emit-seq ;

: pad-bytes ( seq -- newseq )
    dup length bootstrap-cell align 0 pad-tail ;

: extended-part ( str -- str' )
    dup [ 128 < ] all? [ drop f ] [
        [ -7 shift 1 bitxor ] { } map-as
        big-endian get
        [ [ 2 >be ] { } map-as ]
        [ [ 2 >le ] { } map-as ] if
        B{ } join
    ] if ;

: ascii-part ( str -- str' )
    [
        [ 128 mod ] [ 128 >= ] bi
        [ 128 bitor ] when
    ] B{ } map-as ;

: emit-string ( string -- ptr )
    [ length ] [ extended-part ' ] [ ] tri
    string [
        [ emit-fixnum ]
        [ emit ]
        [ f ' emit ascii-part pad-bytes emit-bytes ]
        tri*
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    [ emit-string ] cache-eql-object ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    [ assert-empty ] [
        [ 0 emit-fixnum ] emit-object
    ] bi* ;

M: byte-array '
    [
        byte-array [
            dup length emit-fixnum
            bootstrap-cell 4 = [ 0 emit 0 emit ] when
            pad-bytes emit-bytes
        ] emit-object
    ] cache-eq-object ;

! Tuples
ERROR: tuple-removed class ;

: require-tuple-layout ( word -- layout )
    dup tuple-layout [ ] [ tuple-removed ] ?if ;

: (emit-tuple) ( tuple -- pointer )
    [ tuple-slots ]
    [ class transfer-word require-tuple-layout ] bi prefix [ ' ] map
    tuple [ emit-seq ] emit-object ;

: emit-tuple ( tuple -- pointer )
    dup class name>> "tombstone" =
    [ [ (emit-tuple) ] cache-eql-object ]
    [ [ (emit-tuple) ] cache-eq-object ]
    if ;

M: tuple ' emit-tuple ;

M: tombstone '
    state>> "((tombstone))" "((empty))" ?
    "hashtables.private" lookup def>> first
    [ emit-tuple ] cache-eql-object ;

! Arrays
: emit-array ( array -- offset )
    [ ' ] map array [ [ length emit-fixnum ] [ emit-seq ] bi ] emit-object ;

M: array ' [ emit-array ] cache-eq-object ;

! This is a hack. We need to detect arrays which are tuple
! layout arrays so that they can be internalized, but making
! them a built-in type is not worth it.
PREDICATE: tuple-layout-array < array
    dup length 5 >= [
        [ first tuple-class? ]
        [ second fixnum? ]
        [ third fixnum? ]
        tri and and
    ] [ drop f ] if ;

M: tuple-layout-array '
    [
        [ dup integer? [ <fake-bignum> ] when ] map
        emit-array
    ] cache-eql-object ;

! Quotations

M: quotation '
    [
        array>> '
        quotation [
            emit ! array
            f ' emit ! cached-effect
            f ' emit ! cache-counter
            0 emit ! xt
            0 emit ! code
        ] emit-object
    ] cache-eql-object ;

! End of the image

: emit-words ( -- )
    all-words [ emit-word ] each ;

: emit-global ( -- )
    {
        dictionary source-files builtins
        update-map implementors-map
    } [ [ bootstrap-word ] [ get ] bi ] H{ } map>assoc
    {
        class<=-cache class-not-cache classes-intersect-cache
        class-and-cache class-or-cache next-method-quot-cache
    } [ H{ } clone ] H{ } map>assoc assoc-union
    bootstrap-global set ;

: emit-jit-data ( -- )
    \ if jit-if-word set
    \ do-primitive jit-primitive-word set
    \ dip jit-dip-word set
    \ 2dip jit-2dip-word set
    \ 3dip jit-3dip-word set
    \ (execute) jit-execute-word set
    \ inline-cache-miss \ pic-miss-word set
    \ inline-cache-miss-tail \ pic-miss-tail-word set
    \ mega-cache-lookup \ mega-lookup-word set
    \ mega-cache-miss \ mega-miss-word set
    \ declare jit-declare-word set
    [ undefined ] undefined-quot set ;

: emit-userenvs ( -- )
    userenvs get keys [ emit-userenv ] each ;

: fixup-header ( -- )
    heap-size data-heap-size-offset fixup ;

: build-image ( -- image )
    800000 <vector> image set
    20000 <hashtable> objects set
    emit-header t, 0, 1, -1,
    "Building generic words..." print flush
    remake-generics
    "Serializing words..." print flush
    emit-words
    "Serializing JIT data..." print flush
    emit-jit-data
    "Serializing global namespace..." print flush
    emit-global
    "Serializing user environment..." print flush
    emit-userenvs
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
    bootstrap-cell big-endian get
    [ '[ _ >be write ] each ]
    [ '[ _ >le write ] each ] if ;

: write-image ( image -- )
    "Writing image to " write
    architecture get boot-image-name resource-path
    [ write "..." print flush ]
    [ binary [ (write-image) ] with-file-writer ] bi ;

PRIVATE>

: make-image ( arch -- )
    [
        architecture set
        "resource:/core/bootstrap/stage1.factor" run-file
        build-image
        write-image
    ] with-scope ;

: make-images ( -- )
    images [ make-image ] each ;
