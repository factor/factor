! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: bootstrap.primitives
USING: alien arrays byte-arrays generic hashtables
hashtables.private io kernel math namespaces parser sequences
strings vectors words quotations assocs layouts classes tuples
kernel.private vocabs vocabs.loader source-files definitions
slots classes.union words.private ;

! Some very tricky code creating a bootstrap embryo in the
! host image.

"Creating primitives and basic runtime structures..." print flush

load-help? off
crossref off
changed-words off

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab vocab-words bootstrap-syntax set

"resource:core/bootstrap/syntax.factor" parse-file
H{ } clone dictionary set
call

! Create some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "arrays"
    "bit-arrays"
    "byte-arrays"
    "classes.private"
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
    "threads.private"
    "tools.profiler.private"
    "tuples"
    "tuples.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
} [
    dup find-vocab-root swap create-vocab
    [ set-vocab-root ] keep
    f swap set-vocab-source-loaded?
] each

H{ } clone source-files set
H{ } clone class<map set
H{ } clone update-map set

: make-primitive ( word vocab n -- ) >r create r> define ;

{
    { "(execute)" "words.private" }
    { "(call)" "kernel.private" }
    { "uncurry" "kernel.private" }
    { "string>sbuf" "sbufs.private" }
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
    { "update-xt" "words" }
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
    { "(stat)" "io.files.private" }
    { "(directory)" "io.files.private" }
    { "data-gc" "memory" }
    { "code-gc" "memory" }
    { "gc-time" "memory" }
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
    { "type" "kernel.private" }
    { "tag" "kernel.private" }
    { "cwd" "io.files" }
    { "cd" "io.files" }
    { "add-compiled-block" "generator" }
    { "dlopen" "alien" }
    { "dlsym" "alien" }
    { "dlclose" "alien" }
    { "<byte-array>" "byte-arrays" }
    { "<bit-array>" "bit-arrays" }
    { "<displaced-alien>" "alien" }
    { "alien-signed-cell" "alien" }
    { "set-alien-signed-cell" "alien" }
    { "alien-unsigned-cell" "alien" }
    { "set-alien-unsigned-cell" "alien" }
    { "alien-signed-8" "alien" }
    { "set-alien-signed-8" "alien" }
    { "alien-unsigned-8" "alien" }
    { "set-alien-unsigned-8" "alien" }
    { "alien-signed-4" "alien" }
    { "set-alien-signed-4" "alien" }
    { "alien-unsigned-4" "alien" }
    { "set-alien-unsigned-4" "alien" }
    { "alien-signed-2" "alien" }
    { "set-alien-signed-2" "alien" }
    { "alien-unsigned-2" "alien" }
    { "set-alien-unsigned-2" "alien" }
    { "alien-signed-1" "alien" }
    { "set-alien-signed-1" "alien" }
    { "alien-unsigned-1" "alien" }
    { "set-alien-unsigned-1" "alien" }
    { "alien-float" "alien" }
    { "set-alien-float" "alien" }
    { "alien-double" "alien" }
    { "set-alien-double" "alien" }
    { "alien-cell" "alien" }
    { "set-alien-cell" "alien" }
    { "alien>char-string" "alien" }
    { "string>char-alien" "alien" }
    { "alien>u16-string" "alien" }
    { "string>u16-alien" "alien" }
    { "(throw)" "kernel.private" }
    { "string>memory" "alien" }
    { "memory>string" "alien" }
    { "alien-address" "alien" }
    { "slot" "slots.private" }
    { "set-slot" "slots.private" }
    { "char-slot" "strings.private" }
    { "set-char-slot" "strings.private" }
    { "resize-array" "arrays" }
    { "resize-string" "strings" }
    { "(hashtable)" "hashtables.private" }
    { "<array>" "arrays" }
    { "begin-scan" "memory" }
    { "next-object" "memory" }
    { "end-scan" "memory" }
    { "size" "memory" }
    { "die" "kernel" }
    { "finalize-compile" "generator" }
    { "fopen" "io.streams.c" }
    { "fgetc" "io.streams.c" }
    { "fread" "io.streams.c" }
    { "fwrite" "io.streams.c" }
    { "fflush" "io.streams.c" }
    { "fclose" "io.streams.c" }
    { "<wrapper>" "kernel" }
    { "(clone)" "kernel" }
    { "array>vector" "vectors.private" }
    { "<string>" "strings" }
    { "(>tuple)" "tuples.private" }
    { "array>quotation" "quotations.private" }
    { "quotation-xt" "quotations" }
    { "<tuple>" "tuples.private" }
    { "tuple>array" "tuples" }
    { "profiling" "tools.profiler.private" }
    { "become" "tuples.private" }
    { "(sleep)" "threads.private" }
    { "<float-array>" "float-arrays" }
    { "curry" "kernel" }
    { "<tuple-boa>" "tuples.private" }
	{ "class-hash" "kernel.private" }
    { "callstack>array" "kernel" }
    { "array>callstack" "kernel" }
}
dup length [ >r first2 r> make-primitive ] 2each

! Okay, now we have primitives fleshed out. Bring up the generic
! word system.
: builtin-predicate ( class predicate -- )
    [
        over "type" word-prop dup
        \ tag-mask get < \ tag \ type ? , , \ eq? ,
    ] [ ] make define-predicate ;

: register-builtin ( class -- )
    dup "type" word-prop builtins get set-nth ;

: intern-slots ( spec -- spec )
    [
        [ dup array? [ first2 create ] when ] map
        { slot-spec f } swap append >tuple
    ] map ;

: lookup-type-number ( word -- n )
    global [ target-word ] bind type-number ;

: define-builtin ( symbol predicate slotspec -- )
    >r dup make-inline >r
    dup dup lookup-type-number "type" set-word-prop
    dup f f builtin-class define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

H{ } clone typemap set
num-types get f <array> builtins set

! These symbols are needed by the code that executes below
{
    { "object" "kernel" }
    { "null" "kernel" }
} [ create drop ] assoc-each

"fixnum" "math" create "fixnum?" "math" create { } define-builtin
"fixnum" "math" create ">fixnum" "math" create 1quotation "coercer" set-word-prop

"bignum" "math" create "bignum?" "math" create { } define-builtin
"bignum" "math" create ">bignum" "math" create 1quotation "coercer" set-word-prop

"tuple" "kernel" create "tuple?" "kernel" create
{ } define-builtin

"ratio" "math" create "ratio?" "math" create
{
    {
        { "integer" "math" }
        "numerator"
        1
        { "numerator" "math" }
        f
    }
    {
        { "integer" "math" }
        "denominator"
        2
        { "denominator" "math" }
        f
    }
} define-builtin

"float" "math" create "float?" "math" create { } define-builtin
"float" "math" create ">float" "math" create 1quotation "coercer" set-word-prop

"complex" "math" create "complex?" "math" create
{
    {
        { "real" "math" }
        "real"
        1
        { "real" "math" }
        f
    }
    {
        { "real" "math" }
        "imaginary"
        2
        { "imaginary" "math" }
        f
    }
} define-builtin

"f" "syntax" lookup "not" "kernel" create
{ } define-builtin

"array" "arrays" create "array?" "arrays" create
{ } define-builtin

"wrapper" "kernel" create "wrapper?" "kernel" create
{
    {
        { "object" "kernel" }
        "wrapped"
        1
        { "wrapped" "kernel" }
        f
    }
} define-builtin

"hashtable" "hashtables" create "hashtable?" "hashtables" create
{
    {
        { "array-capacity" "sequences.private" }
        "count"
        1
        { "hash-count" "hashtables.private" }
        { "set-hash-count" "hashtables.private" }
    } {
        { "array-capacity" "sequences.private" }
        "deleted"
        2
        { "hash-deleted" "hashtables.private" }
        { "set-hash-deleted" "hashtables.private" }
    } {
        { "array" "arrays" }
        "array"
        3
        { "hash-array" "hashtables.private" }
        { "set-hash-array" "hashtables.private" }
    }
} define-builtin

"vector" "vectors" create "vector?" "vectors" create
{
    {
        { "array-capacity" "sequences.private" }
        "fill"
        1
        { "length" "sequences" }
        { "set-fill" "growable" }
    } {
        { "array" "arrays" }
        "underlying"
        2
        { "underlying" "growable" }
        { "set-underlying" "growable" }
    }
} define-builtin

"string" "strings" create "string?" "strings" create
{
    {
        { "array-capacity" "sequences.private" }
        "length"
        1
        { "length" "sequences" }
        f
    }
} define-builtin

"sbuf" "sbufs" create "sbuf?" "sbufs" create
{
    {
        { "array-capacity" "sequences.private" }
        "length"
        1
        { "length" "sequences" }
        { "set-fill" "growable" }
    }
    {
        { "string" "strings" }
        "underlying"
        2
        { "underlying" "growable" }
        { "set-underlying" "growable" }
    }
} define-builtin

"quotation" "quotations" create "quotation?" "quotations" create
{
    {
        { "object" "kernel" }
        "array"
        1
        { "quotation-array" "quotations.private" }
        f
    }
} define-builtin

"dll" "alien" create "dll?" "alien" create
{
    {
        { "byte-array" "byte-arrays" }
        "path"
        1
        { "(dll-path)" "alien" }
        f
    }
}
define-builtin

"alien" "alien" create "alien?" "alien" create
{
    {
        { "c-ptr" "alien" }
        "alien"
        1
        { "underlying-alien" "alien" }
        f
    } {
        { "object" "kernel" }
        "expired?"
        2
        { "expired?" "alien" }
        f
    }
}
define-builtin

"word" "words" create "word?" "words" create
{
    {
        { "object" "kernel" }
        "name"
        2
        { "word-name" "words" }
        { "set-word-name" "words" }
    }
    {
        { "object" "kernel" }
        "vocabulary"
        3
        { "word-vocabulary" "words" }
        { "set-word-vocabulary" "words" }
    }
    {
        { "object" "kernel" }
        "def"
        4
        { "word-def" "words" }
        { "set-word-def" "words.private" }
    }
    {
        { "object" "kernel" }
        "props"
        5
        { "word-props" "words" }
        { "set-word-props" "words" }
    }
    {
        { "object" "kernel" }
        "?"
        6
        { "compiled?" "words" }
        f
    }
    {
        { "fixnum" "math" }
        "counter"
        7
        { "profile-counter" "tools.profiler.private" }
        { "set-profile-counter" "tools.profiler.private" }
    }
} define-builtin

"byte-array" "byte-arrays" create
"byte-array?" "byte-arrays" create
{ } define-builtin

"bit-array" "bit-arrays" create
"bit-array?" "bit-arrays" create
{ } define-builtin

"float-array" "float-arrays" create
"float-array?" "float-arrays" create
{ } define-builtin

"curry" "kernel" create
"curry?" "kernel" create
{
    {
        { "object" "kernel" }
        "obj"
        1
        { "curry-obj" "kernel" }
        f
    }
    {
        { "object" "kernel" }
        "obj"
        2
        { "curry-quot" "kernel" }
        f
    }
} define-builtin

"callstack" "kernel" create "callstack?" "kernel" create
{ } define-builtin

! Define general-t type, which is any object that is not f.
"general-t" "kernel" create
"f" "syntax" lookup builtins get remove [ ] subset f union-class
define-class

! Catch-all class for providing a default method.
"object" "kernel" create [ drop t ] "predicate" set-word-prop
"object" "kernel" create
builtins get [ ] subset f union-class define-class

! Class of objects with object tag
"hi-tag" "classes.private" create
builtins get num-tags get tail f union-class define-class

! Null class with no instances.
"null" "kernel" create [ drop f ] "predicate" set-word-prop
"null" "kernel" create { } f union-class define-class

! Create special tombstone values
"tombstone" "hashtables.private" create { } define-tuple-class

"((empty))" "hashtables.private" create
"tombstone" "hashtables.private" lookup f
2array >tuple 1quotation define-inline

"((tombstone))" "hashtables.private" create
"tombstone" "hashtables.private" lookup t
2array >tuple 1quotation define-inline

! Bump build number
"build" "kernel" create build 1+ 1quotation define-compound
