! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic assocs hashtables assocs
hashtables.private io io.binary io.files io.encodings.binary
io.pathnames kernel kernel.private math namespaces make parser
prettyprint sequences sequences.private strings sbufs vectors words
quotations assocs system layouts splitting grouping growable classes
classes.builtin classes.tuple classes.tuple.private vocabs
vocabs.loader source-files definitions debugger quotations.private
sequences.private combinators math.order math.private accessors
slots.private generic.single.private compiler.units compiler.constants
fry ;
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
TUPLE: id obj ;

C: <id> id

M: id hashcode* obj>> hashcode* ;

GENERIC: (eql?) ( obj1 obj2 -- ? )

: eql? ( obj1 obj2 -- ? )
    [ (eql?) ] [ [ class ] bi@ = ] 2bi and ;

M: integer (eql?) = ;

M: sequence (eql?)
    over sequence? [
        2dup [ length ] bi@ =
        [ [ eql? ] 2all? ] [ 2drop f ] if
    ] [ 2drop f ] if ;

M: object (eql?) = ;

M: id equal?
    over id? [ [ obj>> ] bi@ eql? ] [ 2drop f ] if ;

SYMBOL: objects

: (objects) ( obj -- id assoc ) <id> objects get ; inline

: lookup-object ( obj -- n/f ) (objects) at ;

: put-object ( n obj -- ) (objects) set-at ;

: cache-object ( obj quot -- value )
    [ (objects) ] dip '[ obj>> @ ] cache ; inline

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

SYMBOL: jit-define-rc
SYMBOL: jit-define-rt
SYMBOL: jit-define-offset

: compute-offset ( -- offset )
    building get length jit-define-rc get rc-absolute-cell = bootstrap-cell 4 ? - ;

: jit-rel ( rc rt -- )
    jit-define-rt set
    jit-define-rc set
    compute-offset jit-define-offset set ;

: make-jit ( quot -- quad )
    [
        call( -- )
        jit-define-rc get
        jit-define-rt get
        jit-define-offset get 3array
    ] B{ } make prefix ;

: jit-define ( quot name -- )
    [ make-jit ] dip set ;

: define-sub-primitive ( quot word -- )
    [ make-jit ] dip sub-primitives get set-at ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

! Bootstrap global namesapce
SYMBOL: bootstrap-global

! Boot quotation, set in stage1.factor
SYMBOL: bootstrap-boot-quot

! JIT parameters
SYMBOL: jit-prolog
SYMBOL: jit-primitive-word
SYMBOL: jit-primitive
SYMBOL: jit-word-jump
SYMBOL: jit-word-call
SYMBOL: jit-push-immediate
SYMBOL: jit-if-word
SYMBOL: jit-if-1
SYMBOL: jit-if-2
SYMBOL: jit-dip-word
SYMBOL: jit-dip
SYMBOL: jit-2dip-word
SYMBOL: jit-2dip
SYMBOL: jit-3dip-word
SYMBOL: jit-3dip
SYMBOL: jit-execute-word
SYMBOL: jit-execute-jump
SYMBOL: jit-execute-call
SYMBOL: jit-epilog
SYMBOL: jit-return
SYMBOL: jit-profiling
SYMBOL: jit-save-stack

! PIC stubs
SYMBOL: pic-load
SYMBOL: pic-tag
SYMBOL: pic-hi-tag
SYMBOL: pic-tuple
SYMBOL: pic-hi-tag-tuple
SYMBOL: pic-check-tag
SYMBOL: pic-check
SYMBOL: pic-hit
SYMBOL: pic-miss-word

! Megamorphic dispatch
SYMBOL: mega-lookup
SYMBOL: mega-lookup-word
SYMBOL: mega-miss-word

! Default definition for undefined words
SYMBOL: undefined-quot

: userenvs ( -- assoc )
    H{
        { bootstrap-boot-quot 20 }
        { bootstrap-global 21 }
        { jit-prolog 23 }
        { jit-primitive-word 24 }
        { jit-primitive 25 }
        { jit-word-jump 26 }
        { jit-word-call 27 }
        { jit-if-word 28 }
        { jit-if-1 29 }
        { jit-if-2 30 }
        { jit-epilog 33 }
        { jit-return 34 }
        { jit-profiling 35 }
        { jit-push-immediate 36 }
        { jit-save-stack 38 }
        { jit-dip-word 39 }
        { jit-dip 40 }
        { jit-2dip-word 41 }
        { jit-2dip 42 }
        { jit-3dip-word 43 }
        { jit-3dip 44 }
        { jit-execute-word 45 }
        { jit-execute-jump 46 }
        { jit-execute-call 47 }
        { pic-load 48 }
        { pic-tag 49 }
        { pic-hi-tag 50 }
        { pic-tuple 51 }
        { pic-hi-tag-tuple 52 }
        { pic-check-tag 53 }
        { pic-check 54 }
        { pic-hit 55 }
        { pic-miss-word 56 }
        { mega-lookup 57 }
        { mega-lookup-word 58 }
        { mega-miss-word 59 }
        { undefined-quot 60 }
    } ; inline

: userenv-offset ( symbol -- n )
    userenvs at header-size + ;

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

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

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

: bignum-radix ( -- n ) bignum-bits 2^ 1- ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ dup 0 > ]
    [ [ bignum-bits neg shift ] [ bignum-radix bitand ] bi ]
    produce nip ;

: emit-bignum ( n -- )
    dup dup 0 < [ neg ] when bignum>seq
    [ nip length 1+ emit-fixnum ]
    [ drop 0 < 1 0 ? emit ]
    [ nip emit-seq ]
    2tri ;

M: bignum '
    [
        bignum [ emit-bignum ] emit-object
    ] cache-object ;

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
            align-here double>bits emit-64
        ] emit-object
    ] cache-object ;

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
                    [ direct-entry-def>> , ] ! direct-entry-def
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
    image get [ dup word? [ fixup-word ] when ] change-each ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped>> ' wrapper [ emit ] emit-object ;

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
    [ emit-string ] cache-object ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    [ assert-empty ] [
        [ 0 emit-fixnum ] emit-object
    ] bi* ;

M: byte-array '
    byte-array [
        dup length emit-fixnum
        pad-bytes emit-bytes
    ] emit-object ;

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
    [ [ (emit-tuple) ] cache-object ] [ (emit-tuple) ] if ;

M: tuple ' emit-tuple ;

M: tombstone '
    state>> "((tombstone))" "((empty))" ?
    "hashtables.private" lookup def>> first
    [ emit-tuple ] cache-object ;

! Arrays
: emit-array ( array -- offset )
    [ ' ] map array [ [ length emit-fixnum ] [ emit-seq ] bi ] emit-object ;

M: array ' emit-array ;

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
    ] cache-object ;

! Quotations

M: quotation '
    [
        array>> '
        quotation [
            emit ! array
            f ' emit ! compiled
            f ' emit ! cached-effect
            f ' emit ! cache-counter
            0 emit ! xt
            0 emit ! code
        ] emit-object
    ] cache-object ;

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
    bootstrap-global set
    bootstrap-global emit-userenv ;

: emit-boot-quot ( -- )
    bootstrap-boot-quot emit-userenv ;

: emit-jit-data ( -- )
    \ if jit-if-word set
    \ do-primitive jit-primitive-word set
    \ dip jit-dip-word set
    \ 2dip jit-2dip-word set
    \ 3dip jit-3dip-word set
    \ (execute) jit-execute-word set
    \ inline-cache-miss \ pic-miss-word set
    \ mega-cache-lookup \ mega-lookup-word set
    \ mega-cache-miss \ mega-miss-word set
    [ undefined ] undefined-quot set
    {
        jit-prolog
        jit-primitive-word
        jit-primitive
        jit-word-jump
        jit-word-call
        jit-push-immediate
        jit-if-word
        jit-if-1
        jit-if-2
        jit-dip-word
        jit-dip
        jit-2dip-word
        jit-2dip
        jit-3dip-word
        jit-3dip
        jit-execute-word
        jit-execute-jump
        jit-execute-call
        jit-epilog
        jit-return
        jit-profiling
        jit-save-stack
        pic-load
        pic-tag
        pic-hi-tag
        pic-tuple
        pic-hi-tag-tuple
        pic-check-tag
        pic-check
        pic-hit
        pic-miss-word
        mega-lookup
        mega-lookup-word
        mega-miss-word
        undefined-quot
    } [ emit-userenv ] each ;

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
