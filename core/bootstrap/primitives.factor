! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic hashtables
hashtables.private io kernel math namespaces parser sequences
strings vectors words quotations assocs layouts classes tuples
tuples.private kernel.private vocabs vocabs.loader source-files
definitions slots.deprecated classes.union compiler.units
bootstrap.image.private io.files ;
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
H{ } clone changed-words set
H{ } clone root-cache set
H{ } clone source-files set
H{ } clone update-map set
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

! Create some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "arrays"
    "bit-arrays"
    "bit-vectors"
    "byte-arrays"
    "byte-vectors"
    "classes.private"
    "compiler.units"
    "continuations.private"
    "float-arrays"
    "float-vectors"
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
    "tuples"
    "tuples.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
} [ create-vocab drop ] each

! Builtin classes
: builtin-predicate-quot ( class -- quot )
    [
        "type" word-prop dup
        \ tag-mask get < \ tag \ type ? , , \ eq? ,
    ] [ ] make ;

: define-builtin-predicate ( class -- )
    dup
    dup builtin-predicate-quot define-predicate
    predicate-word make-inline ;

: lookup-type-number ( word -- n )
    global [ target-word ] bind type-number ;

: register-builtin ( class -- )
    dup
    dup lookup-type-number "type" set-word-prop
    dup "type" word-prop builtins get set-nth ;

: define-builtin-slots ( symbol slotspec -- )
    dupd 1 simple-slots
    2dup "slots" set-word-prop
    define-slots ;

: define-builtin ( symbol slotspec -- )
    >r
    dup register-builtin
    dup f f builtin-class define-class
    dup define-builtin-predicate
    r> define-builtin-slots ;

! Forward definitions
"object" "kernel" create t "class" set-word-prop
"object" "kernel" create union-class "metaclass" set-word-prop

"null" "kernel" create drop

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

"tuple-layout" "tuples.private" create {
    {
        { "fixnum" "math" }
        "hashcode"
        { "layout-hashcode" "tuples.private" }
        f
    }
    {
        { "word" "words" }
        "class"
        { "layout-class" "tuples.private" }
        f
    }
    {
        { "fixnum" "math" }
        "size"
        { "layout-size" "tuples.private" }
        f
    }
    {
        { "array" "arrays" }
        "superclasses"
        { "layout-superclasses" "tuples.private" }
        f
    }
    {
        { "fixnum" "math" }
        "echelon"
        { "layout-echelon" "tuples.private" }
        f
    }
} define-builtin

"tuple" "kernel" create { } define-builtin

"tuple" "kernel" lookup
{
    {
        { "object" "kernel" }
        "delegate"
        { "delegate" "kernel" }
        { "set-delegate" "kernel" }
    }
}
define-tuple-slots

"tuple" "kernel" lookup define-tuple-layout

! Define general-t type, which is any object that is not f.
"general-t" "kernel" create
"f" "syntax" lookup builtins get remove [ ] subset f union-class
define-class

"f" "syntax" create [ not ] "predicate" set-word-prop
"f?" "syntax" create "syntax" vocab-words delete-at

"general-t" "kernel" create [ ] "predicate" set-word-prop
"general-t?" "kernel" create "syntax" vocab-words delete-at

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
"tombstone" "hashtables.private" create
"tuple" "kernel" lookup
{ } define-tuple-class

"((empty))" "hashtables.private" create
"tombstone" "hashtables.private" lookup f
2array >tuple 1quotation define-inline

"((tombstone))" "hashtables.private" create
"tombstone" "hashtables.private" lookup t
2array >tuple 1quotation define-inline

! Some tuple classes
"hashtable" "hashtables" create
"tuple" "kernel" lookup
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
"tuple" "kernel" lookup
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
"tuple" "kernel" lookup
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
"tuple" "kernel" lookup
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

"bit-vector" "bit-vectors" create
"tuple" "kernel" lookup
{
    {
        { "bit-array" "bit-arrays" }
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

"float-vector" "float-vectors" create
"tuple" "kernel" lookup
{
    {
        { "float-array" "float-arrays" }
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
"tuple" "kernel" lookup
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
dup f "inline" set-word-prop
dup tuple-layout [ <tuple-boa> ] curry define

"compose" "kernel" create
"tuple" "kernel" lookup
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
dup f "inline" set-word-prop
dup tuple-layout [ <tuple-boa> ] curry define

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
    { "alien>char-string" "alien" }
    { "string>char-alien" "alien" }
    { "alien>u16-string" "alien" }
    { "string>u16-alien" "alien" }
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
    { "<tuple>" "tuples.private" }
    { "<tuple-layout>" "tuples.private" }
    { "profiling" "tools.profiler.private" }
    { "become" "kernel.private" }
    { "(sleep)" "threads.private" }
    { "<float-array>" "float-arrays" }
    { "<tuple-boa>" "tuples.private" }
    { "class-hash" "kernel.private" }
    { "callstack>array" "kernel" }
    { "innermost-frame-quot" "kernel.private" }
    { "innermost-frame-scan" "kernel.private" }
    { "set-innermost-frame-quot" "kernel.private" }
    { "call-clear" "kernel" }
    { "(os-envs)" "system.private" }
    { "(set-os-envs)" "system.private" }
    { "resize-byte-array" "byte-arrays" }
    { "resize-bit-array" "bit-arrays" }
    { "resize-float-array" "float-arrays" }
    { "dll-valid?" "alien" }
}
dup length [ >r first2 r> make-primitive ] 2each

! Bump build number
"build" "kernel" create build 1+ 1quotation define
