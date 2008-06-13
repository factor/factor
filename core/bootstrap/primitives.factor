! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic hashtables
hashtables.private io kernel math namespaces parser sequences
strings vectors words quotations assocs layouts classes
classes.builtin classes.tuple classes.tuple.private
kernel.private vocabs vocabs.loader source-files definitions
slots.deprecated classes.union classes.intersection
compiler.units bootstrap.image.private io.files accessors
combinators ;
IN: bootstrap.primitives

"Creating primitives and basic runtime structures..." print flush

crossref off

"resource:core/bootstrap/syntax.factor" parse-file

"resource:core/cpu/" architecture get {
    { "x86.32" "x86/32" }
    { "x86.64" "x86/64" }
    { "linux-ppc" "ppc/linux" }
    { "macosx-ppc" "ppc/macosx" }
    { "arm" "arm" }
} at "/bootstrap.factor" 3append parse-file

"resource:core/bootstrap/layouts/layouts.factor" parse-file

! Now we have ( syntax-quot arch-quot layouts-quot ) on the stack

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab vocab-words bootstrap-syntax set
H{ } clone dictionary set
H{ } clone new-classes set
H{ } clone changed-definitions set
H{ } clone forgotten-definitions set
H{ } clone root-cache set
H{ } clone source-files set
H{ } clone update-map set
H{ } clone implementors-map set
init-caches

! Vocabulary for slot accessors
"accessors" create-vocab drop

! Trivial recompile hook. We don't want to touch the code heap
! during stage1 bootstrap, it would just waste time.
[ drop { } ] recompile-hook set

call
call
call

! After we execute bootstrap/layouts
num-types get f <array> builtins set

bootstrapping? on

! Create some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "arrays"
    "bit-arrays"
    "byte-arrays"
    "byte-vectors"
    "classes.private"
    "classes.tuple"
    "classes.tuple.private"
    "compiler.units"
    "continuations.private"
    "float-arrays"
    "generator"
    "growable"
    "hashtables"
    "hashtables.private"
    "io"
    "io.files"
    "io.files.private"
    "io.streams.c"
    "kernel"
    "kernel.private"
    "math"
    "math.private"
    "memory"
    "quotations"
    "quotations.private"
    "sbufs"
    "sbufs.private"
    "scratchpad"
    "sequences"
    "sequences.private"
    "slots.private"
    "strings"
    "strings.private"
    "system"
    "system.private"
    "threads.private"
    "tools.profiler.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
} [ create-vocab drop ] each

! Builtin classes
: lo-tag-eq-quot ( n -- quot )
    [ \ tag , , \ eq? , ] [ ] make ;

: hi-tag-eq-quot ( n -- quot )
    [
        [ dup tag ] % \ hi-tag tag-number , \ eq? ,
        [ [ hi-tag ] % , \ eq? , ] [ ] make ,
        [ drop f ] ,
        \ if ,
    ] [ ] make ;

: builtin-predicate-quot ( class -- quot )
    "type" word-prop
    dup tag-mask get <
    [ lo-tag-eq-quot ] [ hi-tag-eq-quot ] if ;

: define-builtin-predicate ( class -- )
    dup builtin-predicate-quot define-predicate ;

: lookup-type-number ( word -- n )
    global [ target-word ] bind type-number ;

: register-builtin ( class -- )
    [ dup lookup-type-number "type" set-word-prop ]
    [ dup "type" word-prop builtins get set-nth ]
    [ f f f builtin-class define-class ]
    tri ;

: define-builtin-slots ( symbol slotspec -- )
    [ drop ] [ 1 simple-slots ] 2bi
    [ "slots" set-word-prop ] [ define-slots ] 2bi ;

: define-builtin ( symbol slotspec -- )
    >r [ define-builtin-predicate ] keep
    r> define-builtin-slots ;

"fixnum" "math" create register-builtin
"bignum" "math" create register-builtin
"tuple" "kernel" create register-builtin
"ratio" "math" create register-builtin
"float" "math" create register-builtin
"complex" "math" create register-builtin
"f" "syntax" lookup register-builtin
"array" "arrays" create register-builtin
"wrapper" "kernel" create register-builtin
"float-array" "float-arrays" create register-builtin
"callstack" "kernel" create register-builtin
"string" "strings" create register-builtin
"bit-array" "bit-arrays" create register-builtin
"quotation" "quotations" create register-builtin
"dll" "alien" create register-builtin
"alien" "alien" create register-builtin
"word" "words" create register-builtin
"byte-array" "byte-arrays" create register-builtin
"tuple-layout" "classes.tuple.private" create register-builtin

! Catch-all class for providing a default method.
"object" "kernel" create
[ f f { } intersection-class define-class ]
[ [ drop t ] "predicate" set-word-prop ]
bi

"object?" "kernel" vocab-words delete-at

! Class of objects with object tag
"hi-tag" "kernel.private" create
builtins get num-tags get tail define-union-class

! Empty class with no instances
"null" "kernel" create
[ f { } f union-class define-class ]
[ [ drop f ] "predicate" set-word-prop ]
bi

"null?" "kernel" vocab-words delete-at

"fixnum" "math" create { } define-builtin
"fixnum" "math" create ">fixnum" "math" create 1quotation "coercer" set-word-prop

"bignum" "math" create { } define-builtin
"bignum" "math" create ">bignum" "math" create 1quotation "coercer" set-word-prop

"ratio" "math" create {
    {
        { "integer" "math" }
        "numerator"
        { "numerator" "math" }
        f
    }
    {
        { "integer" "math" }
        "denominator"
        { "denominator" "math" }
        f
    }
} define-builtin

"float" "math" create { } define-builtin
"float" "math" create ">float" "math" create 1quotation "coercer" set-word-prop

"complex" "math" create {
    {
        { "real" "math" }
        "real-part"
        { "real-part" "math" }
        f
    }
    {
        { "real" "math" }
        "imaginary-part"
        { "imaginary-part" "math" }
        f
    }
} define-builtin

"f" "syntax" lookup { } define-builtin

"array" "arrays" create { } define-builtin

"wrapper" "kernel" create {
    {
        { "object" "kernel" }
        "wrapped"
        { "wrapped" "kernel" }
        f
    }
} define-builtin

"string" "strings" create {
    {
        { "array-capacity" "sequences.private" }
        "length"
        { "length" "sequences" }
        f
    } {
        { "object" "kernel" }
        "aux"
        { "string-aux" "strings.private" }
        { "set-string-aux" "strings.private" }
    }
} define-builtin

"quotation" "quotations" create {
    {
        { "object" "kernel" }
        "array"
        { "quotation-array" "quotations.private" }
        f
    }
    {
        { "object" "kernel" }
        "compiled?"
        { "quotation-compiled?" "quotations" }
        f
    }
} define-builtin

"dll" "alien" create {
    {
        { "byte-array" "byte-arrays" }
        "path"
        { "(dll-path)" "alien" }
        f
    }
}
define-builtin

"alien" "alien" create {
    {
        { "c-ptr" "alien" }
        "alien"
        { "underlying-alien" "alien" }
        f
    } {
        { "object" "kernel" }
        "expired?"
        { "expired?" "alien" }
        f
    }
}
define-builtin

"word" "words" create {
    f
    {
        { "object" "kernel" }
        "name"
        { "word-name" "words" }
        { "set-word-name" "words" }
    }
    {
        { "object" "kernel" }
        "vocabulary"
        { "word-vocabulary" "words" }
        { "set-word-vocabulary" "words" }
    }
    {
        { "quotation" "quotations" }
        "def"
        { "word-def" "words" }
        { "set-word-def" "words.private" }
    }
    {
        { "object" "kernel" }
        "props"
        { "word-props" "words" }
        { "set-word-props" "words" }
    }
    {
        { "object" "kernel" }
        "compiled?"
        { "compiled?" "words" }
        f
    }
    {
        { "fixnum" "math" }
        "counter"
        { "profile-counter" "tools.profiler.private" }
        { "set-profile-counter" "tools.profiler.private" }
    }
} define-builtin

"byte-array" "byte-arrays" create { } define-builtin

"bit-array" "bit-arrays" create { } define-builtin

"float-array" "float-arrays" create { } define-builtin

"callstack" "kernel" create { } define-builtin

"tuple-layout" "classes.tuple.private" create {
    {
        { "fixnum" "math" }
        "hashcode"
        { "layout-hashcode" "classes.tuple.private" }
        f
    }
    {
        { "word" "words" }
        "class"
        { "layout-class" "classes.tuple.private" }
        f
    }
    {
        { "fixnum" "math" }
        "size"
        { "layout-size" "classes.tuple.private" }
        f
    }
    {
        { "array" "arrays" }
        "superclasses"
        { "layout-superclasses" "classes.tuple.private" }
        f
    }
    {
        { "fixnum" "math" }
        "echelon"
        { "layout-echelon" "classes.tuple.private" }
        f
    }
} define-builtin

"tuple" "kernel" create {
    [ { } define-builtin ]
    [ { "delegate" } "slot-names" set-word-prop ]
    [ define-tuple-layout ]
    [
        {
            {
                { "object" "kernel" }
                "delegate"
                { "delegate" "kernel" }
                { "set-delegate" "kernel" }
            }
        }
        [ drop ] [ generate-tuple-slots ] 2bi
        [ "slots" set-word-prop ]
        [ define-slots ]
        2bi
    ]
} cleave

"f" "syntax" create [ not ] "predicate" set-word-prop
"f?" "syntax" vocab-words delete-at

! Create special tombstone values
"tombstone" "hashtables.private" create
tuple
{ } define-tuple-class

"((empty))" "hashtables.private" create
"tombstone" "hashtables.private" lookup f
2array >tuple 1quotation define-inline

"((tombstone))" "hashtables.private" create
"tombstone" "hashtables.private" lookup t
2array >tuple 1quotation define-inline

! Some tuple classes
"hashtable" "hashtables" create
tuple
{
    {
        { "array-capacity" "sequences.private" }
        "count"
        { "hash-count" "hashtables.private" }
        { "set-hash-count" "hashtables.private" }
    } {
        { "array-capacity" "sequences.private" }
        "deleted"
        { "hash-deleted" "hashtables.private" }
        { "set-hash-deleted" "hashtables.private" }
    } {
        { "array" "arrays" }
        "array"
        { "hash-array" "hashtables.private" }
        { "set-hash-array" "hashtables.private" }
    }
} define-tuple-class

"sbuf" "sbufs" create
tuple
{
    {
        { "string" "strings" }
        "underlying"
        { "underlying" "growable" }
        { "set-underlying" "growable" }
    } {
        { "array-capacity" "sequences.private" }
        "length"
        { "length" "sequences" }
        { "set-fill" "growable" }
    }
} define-tuple-class

"vector" "vectors" create
tuple
{
    {
        { "array" "arrays" }
        "underlying"
        { "underlying" "growable" }
        { "set-underlying" "growable" }
    } {
        { "array-capacity" "sequences.private" }
        "fill"
        { "length" "sequences" }
        { "set-fill" "growable" }
    }
} define-tuple-class

"byte-vector" "byte-vectors" create
tuple
{
    {
        { "byte-array" "byte-arrays" }
        "underlying"
        { "underlying" "growable" }
        { "set-underlying" "growable" }
    } {
        { "array-capacity" "sequences.private" }
        "fill"
        { "length" "sequences" }
        { "set-fill" "growable" }
    }
} define-tuple-class

"curry" "kernel" create
tuple
{
    {
        { "object" "kernel" }
        "obj"
        { "curry-obj" "kernel" }
        f
    } {
        { "object" "kernel" }
        "quot"
        { "curry-quot" "kernel" }
        f
    }
} define-tuple-class

"curry" "kernel" lookup
[ f "inline" set-word-prop ]
[ ]
[ tuple-layout [ <tuple-boa> ] curry ] tri
(( obj quot -- curry )) define-declared

"compose" "kernel" create
tuple
{
    {
        { "object" "kernel" }
        "first"
        { "compose-first" "kernel" }
        f
    } {
        { "object" "kernel" }
        "second"
        { "compose-second" "kernel" }
        f
    }
} define-tuple-class

"compose" "kernel" lookup
[ f "inline" set-word-prop ]
[ ]
[ tuple-layout [ <tuple-boa> ] curry ] tri
(( quot1 quot2 -- compose )) define-declared

! Primitive words
: make-primitive ( word vocab n -- )
    >r create dup reset-word r>
    [ do-primitive ] curry [ ] like define ;

{
    { "(execute)" "words.private" }
    { "(call)" "kernel.private" }
    { "bignum>fixnum" "math.private" }
    { "float>fixnum" "math.private" }
    { "fixnum>bignum" "math.private" }
    { "float>bignum" "math.private" }
    { "fixnum>float" "math.private" }
    { "bignum>float" "math.private" }
    { "<ratio>" "math.private" }
    { "string>float" "math.private" }
    { "float>string" "math.private" }
    { "float>bits" "math" }
    { "double>bits" "math" }
    { "bits>float" "math" }
    { "bits>double" "math" }
    { "<complex>" "math.private" }
    { "fixnum+" "math.private" }
    { "fixnum+fast" "math.private" }
    { "fixnum-" "math.private" }
    { "fixnum-fast" "math.private" }
    { "fixnum*" "math.private" }
    { "fixnum*fast" "math.private" }
    { "fixnum/i" "math.private" }
    { "fixnum-mod" "math.private" }
    { "fixnum/mod" "math.private" }
    { "fixnum-bitand" "math.private" }
    { "fixnum-bitor" "math.private" }
    { "fixnum-bitxor" "math.private" }
    { "fixnum-bitnot" "math.private" }
    { "fixnum-shift" "math.private" }
    { "fixnum-shift-fast" "math.private" }
    { "fixnum<" "math.private" }
    { "fixnum<=" "math.private" }
    { "fixnum>" "math.private" }
    { "fixnum>=" "math.private" }
    { "bignum=" "math.private" }
    { "bignum+" "math.private" }
    { "bignum-" "math.private" }
    { "bignum*" "math.private" }
    { "bignum/i" "math.private" }
    { "bignum-mod" "math.private" }
    { "bignum/mod" "math.private" }
    { "bignum-bitand" "math.private" }
    { "bignum-bitor" "math.private" }
    { "bignum-bitxor" "math.private" }
    { "bignum-bitnot" "math.private" }
    { "bignum-shift" "math.private" }
    { "bignum<" "math.private" }
    { "bignum<=" "math.private" }
    { "bignum>" "math.private" }
    { "bignum>=" "math.private" }
    { "bignum-bit?" "math.private" }
    { "bignum-log2" "math.private" }
    { "byte-array>bignum" "math" }
    { "float=" "math.private" }
    { "float+" "math.private" }
    { "float-" "math.private" }
    { "float*" "math.private" }
    { "float/f" "math.private" }
    { "float-mod" "math.private" }
    { "float<" "math.private" }
    { "float<=" "math.private" }
    { "float>" "math.private" }
    { "float>=" "math.private" }
    { "<word>" "words" }
    { "word-xt" "words" }
    { "drop" "kernel" }
    { "2drop" "kernel" }
    { "3drop" "kernel" }
    { "dup" "kernel" }
    { "2dup" "kernel" }
    { "3dup" "kernel" }
    { "rot" "kernel" }
    { "-rot" "kernel" }
    { "dupd" "kernel" }
    { "swapd" "kernel" }
    { "nip" "kernel" }
    { "2nip" "kernel" }
    { "tuck" "kernel" }
    { "over" "kernel" }
    { "pick" "kernel" }
    { "swap" "kernel" }
    { ">r" "kernel" }
    { "r>" "kernel" }
    { "eq?" "kernel" }
    { "getenv" "kernel.private" }
    { "setenv" "kernel.private" }
    { "(exists?)" "io.files.private" }
    { "(directory)" "io.files.private" }
    { "gc" "memory" }
    { "gc-stats" "memory" }
    { "save-image" "memory" }
    { "save-image-and-exit" "memory" }
    { "datastack" "kernel" }
    { "retainstack" "kernel" }
    { "callstack" "kernel" }
    { "set-datastack" "kernel" }
    { "set-retainstack" "kernel" }
    { "set-callstack" "kernel" }
    { "exit" "system" }
    { "data-room" "memory" }
    { "code-room" "memory" }
    { "os-env" "system" }
    { "millis" "system" }
    { "tag" "kernel.private" }
    { "modify-code-heap" "compiler.units" }
    { "dlopen" "alien" }
    { "dlsym" "alien" }
    { "dlclose" "alien" }
    { "<byte-array>" "byte-arrays" }
    { "<bit-array>" "bit-arrays" }
    { "<displaced-alien>" "alien" }
    { "alien-signed-cell" "alien.accessors" }
    { "set-alien-signed-cell" "alien.accessors" }
    { "alien-unsigned-cell" "alien.accessors" }
    { "set-alien-unsigned-cell" "alien.accessors" }
    { "alien-signed-8" "alien.accessors" }
    { "set-alien-signed-8" "alien.accessors" }
    { "alien-unsigned-8" "alien.accessors" }
    { "set-alien-unsigned-8" "alien.accessors" }
    { "alien-signed-4" "alien.accessors" }
    { "set-alien-signed-4" "alien.accessors" }
    { "alien-unsigned-4" "alien.accessors" }
    { "set-alien-unsigned-4" "alien.accessors" }
    { "alien-signed-2" "alien.accessors" }
    { "set-alien-signed-2" "alien.accessors" }
    { "alien-unsigned-2" "alien.accessors" }
    { "set-alien-unsigned-2" "alien.accessors" }
    { "alien-signed-1" "alien.accessors" }
    { "set-alien-signed-1" "alien.accessors" }
    { "alien-unsigned-1" "alien.accessors" }
    { "set-alien-unsigned-1" "alien.accessors" }
    { "alien-float" "alien.accessors" }
    { "set-alien-float" "alien.accessors" }
    { "alien-double" "alien.accessors" }
    { "set-alien-double" "alien.accessors" }
    { "alien-cell" "alien.accessors" }
    { "set-alien-cell" "alien.accessors" }
    { "(throw)" "kernel.private" }
    { "alien-address" "alien" }
    { "slot" "slots.private" }
    { "set-slot" "slots.private" }
    { "string-nth" "strings.private" }
    { "set-string-nth" "strings.private" }
    { "resize-array" "arrays" }
    { "resize-string" "strings" }
    { "<array>" "arrays" }
    { "begin-scan" "memory" }
    { "next-object" "memory" }
    { "end-scan" "memory" }
    { "size" "memory" }
    { "die" "kernel" }
    { "fopen" "io.streams.c" }
    { "fgetc" "io.streams.c" }
    { "fread" "io.streams.c" }
    { "fputc" "io.streams.c" }
    { "fwrite" "io.streams.c" }
    { "fflush" "io.streams.c" }
    { "fclose" "io.streams.c" }
    { "<wrapper>" "kernel" }
    { "(clone)" "kernel" }
    { "<string>" "strings" }
    { "array>quotation" "quotations.private" }
    { "quotation-xt" "quotations" }
    { "<tuple>" "classes.tuple.private" }
    { "<tuple-layout>" "classes.tuple.private" }
    { "profiling" "tools.profiler.private" }
    { "become" "kernel.private" }
    { "(sleep)" "threads.private" }
    { "<float-array>" "float-arrays" }
    { "<tuple-boa>" "classes.tuple.private" }
    { "callstack>array" "kernel" }
    { "innermost-frame-quot" "kernel.private" }
    { "innermost-frame-scan" "kernel.private" }
    { "set-innermost-frame-quot" "kernel.private" }
    { "call-clear" "kernel" }
    { "(os-envs)" "system.private" }
    { "set-os-env" "system" }
    { "unset-os-env" "system" }
    { "(set-os-envs)" "system.private" }
    { "resize-byte-array" "byte-arrays" }
    { "resize-bit-array" "bit-arrays" }
    { "resize-float-array" "float-arrays" }
    { "dll-valid?" "alien" }
    { "unimplemented" "kernel.private" }
    { "gc-reset" "memory" }
}
dup length [ >r first2 r> make-primitive ] 2each

! Bump build number
"build" "kernel" create build 1+ 1quotation define
