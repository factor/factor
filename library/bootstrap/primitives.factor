! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: alien generic hashtables io kernel kernel-internals lists
math namespaces sequences strings vectors words ;

! Some very tricky code creating a bootstrap embryo in the
! host image.

"Creating primitives and basic runtime structures..." print

! This symbol needs the same hashcode in the target as in the
! host.
vocabularies

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab clone
"generic" vocab clone

<namespace> vocabularies set
f crossref set

vocabularies get [
    "generic" set
    "syntax" set
    reveal
] bind

: set-stack-effect ( { vocab word effect } -- )
    3unseq >r unit search r> dup string? [
        "stack-effect" set-word-prop
    ] [
        "infer-effect" set-word-prop
    ] ifte ;

: make-primitive ( { vocab word effect } n -- )
    >r dup 2unseq create r> f define set-stack-effect ;

{
    { "execute" "words"                       [ [ word ] [ ] ] }
    { "call" "kernel"                         [ [ general-list ] [ ] ] }
    { "ifte" "kernel"                         [ [ object general-list general-list ] [ ] ] }
    { "dispatch" "kernel-internals"           [ [ fixnum vector ] [ ] ] }
    { "cons" "lists"                          [ [ object object ] [ cons ] ] }
    { "<vector>" "vectors"                    [ [ integer ] [ vector ] ] }
    { "rehash-string" "strings"               [ [ string ] [ ] ] }
    { "<sbuf>" "strings"                      [ [ integer ] [ sbuf ] ] }
    { "sbuf>string" "strings"                 [ [ sbuf ] [ string ] ] }
    { ">fixnum" "math"                        [ [ number ] [ fixnum ] ] }
    { ">bignum" "math"                        [ [ number ] [ bignum ] ] }
    { ">float" "math"                         [ [ number ] [ float ] ] }
    { "(fraction>)" "math-internals"          [ [ integer integer ] [ rational ] ] }
    { "str>float" "parser"                    [ [ string ] [ float ] ] }
    { "(unparse-float)" "unparser"            [ [ float ] [ string ] ] }
    { "float>bits" "math"                     [ [ real ] [ integer ] ] }
    { "double>bits" "math"                    [ [ real ] [ integer ] ] }
    { "bits>float" "math"                     [ [ integer ] [ float ] ] }
    { "bits>double" "math"                    [ [ integer ] [ float ] ] }
    { "<complex>" "math-internals"            [ [ real real ] [ number ] ] }
    { "fixnum+" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum-" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum*" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum/i" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum/f" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum-mod" "math-internals"           [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum/mod" "math-internals"           [ [ fixnum fixnum ] [ integer fixnum ] ] }
    { "fixnum-bitand" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitor" "math-internals"         [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitxor" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] }
    { "fixnum-bitnot" "math-internals"        [ [ fixnum ] [ fixnum ] ] }
    { "fixnum-shift" "math-internals"         [ [ fixnum fixnum ] [ integer ] ] }
    { "fixnum<" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum<=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum>" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] }
    { "fixnum>=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] }
    { "bignum=" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum+" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum*" "math-internals"              [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/i" "math-internals"             [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/f" "math-internals"             [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-mod" "math-internals"           [ [ bignum bignum ] [ bignum ] ] }
    { "bignum/mod" "math-internals"           [ [ bignum bignum ] [ bignum bignum ] ] }
    { "bignum-bitand" "math-internals"        [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitor" "math-internals"         [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitxor" "math-internals"        [ [ bignum bignum ] [ bignum ] ] }
    { "bignum-bitnot" "math-internals"        [ [ bignum ] [ bignum ] ] }
    { "bignum-shift" "math-internals"         [ [ bignum bignum ] [ bignum ] ] }
    { "bignum<" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum<=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] }
    { "bignum>" "math-internals"              [ [ bignum bignum ] [ boolean ] ] }
    { "bignum>=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] }
    { "float=" "math-internals"               [ [ bignum bignum ] [ boolean ] ] }
    { "float+" "math-internals"               [ [ float float ] [ float ] ] }
    { "float-" "math-internals"               [ [ float float ] [ float ] ] }
    { "float*" "math-internals"               [ [ float float ] [ float ] ] }
    { "float/f" "math-internals"              [ [ float float ] [ float ] ] }
    { "float<" "math-internals"               [ [ float float ] [ boolean ] ] }
    { "float<=" "math-internals"              [ [ float float ] [ boolean ] ] }
    { "float>" "math-internals"               [ [ float float ] [ boolean ] ] }
    { "float>=" "math-internals"              [ [ float float ] [ boolean ] ] }
    { "facos" "math-internals"                [ [ real ] [ float ] ] }
    { "fasin" "math-internals"                [ [ real ] [ float ] ] }
    { "fatan" "math-internals"                [ [ real ] [ float ] ] }
    { "fatan2" "math-internals"               [ [ real real ] [ float ] ] }
    { "fcos" "math-internals"                 [ [ real ] [ float ] ] }
    { "fexp" "math-internals"                 [ [ real ] [ float ] ] }
    { "fcosh" "math-internals"                [ [ real ] [ float ] ] }
    { "flog" "math-internals"                 [ [ real ] [ float ] ] }
    { "fpow" "math-internals"                 [ [ real real ] [ float ] ] }
    { "fsin" "math-internals"                 [ [ real ] [ float ] ] }
    { "fsinh" "math-internals"                [ [ real ] [ float ] ] }
    { "fsqrt" "math-internals"                [ [ real ] [ float ] ] }
    { "<word>" "words"                        [ [ ] [ word ] ] }
    { "update-xt" "words"                     [ [ word ] [ ] ] }
    { "compiled?" "words"                     [ [ word ] [ boolean ] ] }
    { "drop" "kernel"                         [ [ object ] [ ] ] }
    { "dup" "kernel"                          [ [ object ] [ object object ] ] }
    { "swap" "kernel"                         [ [ object object ] [ object object ] ] }
    { "over" "kernel"                         [ [ object object ] [ object object object ] ] }
    { "pick" "kernel"                         [ [ object object object ] [ object object object object ] ] }
    { ">r" "kernel"                           [ [ object ] [ ] ] }
    { "r>" "kernel"                           [ [ ] [ object ] ] }
    { "eq?" "kernel"                          [ [ object object ] [ boolean ] ] }
    { "getenv" "kernel-internals"             [ [ fixnum ] [ object ] ] }
    { "setenv" "kernel-internals"             [ [ object fixnum ] [ ] ] }
    { "stat" "io"                             [ [ string ] [ general-list ] ] }
    { "(directory)" "io"                      [ [ string ] [ general-list ] ] }
    { "gc" "memory"                           [ [ fixnum ] [ ] ] }
    { "gc-time" "memory"                      [ [ string ] [ ] ] }
    { "save-image" "memory"                   [ [ string ] [ ] ] }
    { "datastack" "kernel"                    " -- ds "          }
    { "callstack" "kernel"                    " -- cs "          }
    { "set-datastack" "kernel"                " ds -- "          }
    { "set-callstack" "kernel"                " cs -- "          }
    { "exit" "kernel"                         [ [ integer ] [ ] ] }
    { "room" "memory"                         [ [ ] [ integer integer integer integer general-list ] ] }
    { "os-env" "kernel"                       [ [ string ] [ object ] ] }
    { "millis" "kernel"                       [ [ ] [ integer ] ] }
    { "(random-int)" "math"                   [ [ ] [ integer ] ] }
    { "type" "kernel"                         [ [ object ] [ fixnum ] ] }
    { "tag" "kernel-internals"                [ [ object ] [ fixnum ] ] }
    { "cwd" "io"                              [ [ ] [ string ] ] }
    { "cd" "io"                               [ [ string ] [ ] ] }
    { "compiled-offset" "assembler"           [ [ ] [ integer ] ] }
    { "set-compiled-offset" "assembler"       [ [ integer ] [ ] ] }
    { "literal-top" "assembler"               [ [ ] [ integer ] ] }
    { "set-literal-top" "assembler"           [ [ integer ] [ ] ] }
    { "address" "memory"                      [ [ object ] [ integer ] ] }
    { "dlopen" "alien"                        [ [ string ] [ dll ] ] }
    { "dlsym" "alien"                         [ [ string object ] [ integer ] ] }
    { "dlclose" "alien"                       [ [ dll ] [ ] ] }
    { "<alien>" "alien"                       [ [ integer ] [ alien ] ] }
    { "<byte-array>" "kernel-internals"       [ [ integer ] [ byte-array ] ] }
    { "<displaced-alien>" "alien"             [ [ integer c-ptr ] [ displaced-alien ] ] }
    { "alien-signed-cell" "alien"             [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-cell" "alien"         [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-cell" "alien"           [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-cell" "alien"       [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-8" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-8" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-8" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-8" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-4" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-4" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-4" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-4" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-2" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-2" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-2" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-2" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-signed-1" "alien"                [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-signed-1" "alien"            [ [ integer c-ptr integer ] [ ] ] }
    { "alien-unsigned-1" "alien"              [ [ c-ptr integer ] [ integer ] ] }
    { "set-alien-unsigned-1" "alien"          [ [ integer c-ptr integer ] [ ] ] }
    { "alien-float" "alien"                   [ [ c-ptr integer ] [ float ] ] }
    { "set-alien-float" "alien"               [ [ float c-ptr integer ] [ ] ] }
    { "alien-double" "alien"                  [ [ c-ptr integer ] [ float ] ] }
    { "set-alien-double" "alien"              [ [ float c-ptr integer ] [ ] ] }
    { "alien-c-string" "alien"                [ [ c-ptr integer ] [ string ] ] }
    { "set-alien-c-string" "alien"            [ [ string c-ptr integer ] [ ] ] }
    { "throw" "errors"                        [ [ object ] [ ] ] }
    { "string>memory" "kernel-internals"      [ [ string integer ] [ ] ] }
    { "memory>string" "kernel-internals"      [ [ integer integer ] [ string ] ] }
    { "alien-address" "alien"                 [ [ alien ] [ integer ] ] }
    { "slot" "kernel-internals"               [ [ object fixnum ] [ object ] ] }
    { "set-slot" "kernel-internals"           [ [ object object fixnum ] [ ] ] }
    { "integer-slot" "kernel-internals"       [ [ object fixnum ] [ integer ] ] }
    { "set-integer-slot" "kernel-internals"   [ [ integer object fixnum ] [ ] ] }
    { "char-slot" "kernel-internals"          [ [ object fixnum ] [ fixnum ] ] }
    { "set-char-slot" "kernel-internals"      [ [ integer object fixnum ] [ ] ] }
    { "resize-array" "kernel-internals"       [ [ integer array ] [ array ] ] }
    { "resize-string" "strings"               [ [ integer string ] [ string ] ] }
    { "<hashtable>" "hashtables"              [ [ number ] [ hashtable ] ] }
    { "<array>" "kernel-internals"            [ [ number ] [ array ] ] }
    { "<tuple>" "kernel-internals"            [ [ number ] [ tuple ] ] }
    { "begin-scan" "memory"                   [ [ ] [ ] ] }
    { "next-object" "memory"                  [ [ ] [ object ] ] }
    { "end-scan" "memory"                     [ [ ] [ ] ] }
    { "size" "memory"                         [ [ object ] [ fixnum ] ] }
    { "die" "kernel"                          [ [ ] [ ] ] }
    { "flush-icache" "assembler"              f }
    [ "fopen"  "io-internals"                 [ [ string string ] [ alien ] ] ]
    { "fgetc" "io-internals"                  [ [ alien ] [ object ] ] }
    { "fwrite" "io-internals"                 [ [ string alien ] [ ] ] }
    { "fflush" "io-internals"                 [ [ alien ] [ ] ] }
    { "fclose" "io-internals"                 [ [ alien ] [ ] ] }
    { "expired?" "alien"                      [ [ object ] [ boolean ] ] }
    { "<wrapper>" "kernel"                    [ [ object ] [ wrapper ] ] }
} dup length 3 swap [ + ] map-with [
    make-primitive
] 2each

! These need a more descriptive comment.
{
    { "drop" "kernel" " x -- " }
    { "dup" "kernel"  " x -- x x " }
    { "swap" "kernel" " x y -- y x " }
    { "over" "kernel" " x y -- x y x " }
    { "pick" "kernel" " x y z -- x y z x " }
    { ">r" "kernel"   " x -- r: x " }
    { "r>" "kernel"   " r: x -- x " }
} [
    set-stack-effect
] each

FORGET: make-primitive
FORGET: set-stack-effect

! Okay, now we have primitives fleshed out. Bring up the generic
! word system.
: builtin-predicate ( class predicate -- )
    [ \ type , over types first , \ eq? , ] make-list
    define-predicate ;

: register-builtin ( class -- )
    dup types first builtins get set-nth ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup intern-symbol
    dup r> 1vector "types" set-word-prop
    dup builtin define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

! Hack
{{ [[ { } null ]] }} typemap set

num-types empty-vector builtins set

"fixnum" "math" create 0 "fixnum?" "math" create { } define-builtin
"fixnum" "math" create 0 "math-priority" set-word-prop
"fixnum" "math" create ">fixnum" [ "math" ] search unit "coercer" set-word-prop

"bignum" "math" create 1 "bignum?" "math" create { } define-builtin
"bignum" "math" create 1 "math-priority" set-word-prop
"bignum" "math" create ">bignum" [ "math" ] search unit "coercer" set-word-prop

"cons" "lists" create 2 "cons?" "lists" create
{ { 0 { "car" "lists" } f } { 1 { "cdr" "lists" } f } } define-builtin

"ratio" "math" create 4 "ratio?" "math" create
{ { 0 { "numerator" "math" } f } { 1 { "denominator" "math" } f } } define-builtin
"ratio" "math" create 2 "math-priority" set-word-prop

"float" "math" create 5 "float?" "math" create { } define-builtin
"float" "math" create 3 "math-priority" set-word-prop
"float" "math" create ">float" [ "math" ] search unit "coercer" set-word-prop

"complex" "math" create 6 "complex?" "math" create
{ { 0 { "real" "math" } f } { 1 { "imaginary" "math" } f } } define-builtin
"complex" "math" create 4 "math-priority" set-word-prop

"t" "!syntax" create 7 "t?" "kernel" create
{ } define-builtin

"array" "kernel-internals" create 8 "array?" "kernel-internals" create
{ } define-builtin

"f" "!syntax" create 9 "not" "kernel" create
{ } define-builtin

"hashtable" "hashtables" create 10 "hashtable?" "hashtables" create {
    { 1 { "hash-size" "hashtables" } { "set-hash-size" "kernel-internals" } }
    { 2 { "hash-array" "kernel-internals" } { "set-hash-array" "kernel-internals" } }
} define-builtin

"vector" "vectors" create 11 "vector?" "vectors" create {
    { 1 { "length" "sequences" } { "set-capacity" "kernel-internals" } }
    { 2 { "underlying" "kernel-internals" } { "set-underlying" "kernel-internals" } }
} define-builtin

"string" "strings" create 12 "string?" "strings" create {
    { 1 { "length" "sequences" } f }
    { 2 { "hashcode" "kernel" } f }
} define-builtin

"sbuf" "strings" create 13 "sbuf?" "strings" create {
    { 1 { "length" "sequences" } { "set-capacity" "kernel-internals" } }
    { 2 { "underlying" "kernel-internals" } { "set-underlying" "kernel-internals" } }
} define-builtin

"wrapper" "kernel" create 14 "wrapper?" "kernel" create
{ { 1 { "wrapped" "kernel" } f } } define-builtin

"dll" "alien" create 15 "dll?" "alien" create
{ { 1 { "dll-path" "alien" } f } } define-builtin

"alien" "alien" create 16 "alien?" "alien" create { } define-builtin

"word" "words" create 17 "word?" "words" create {
    { 1 { "hashcode" "kernel" } f }
    { 4 { "word-def" "words" } { "set-word-def" "words" } }
    { 5 { "word-props" "words" } { "set-word-props" "words" } }
} define-builtin

"tuple" "kernel" create 18 "tuple?" "kernel" create { } define-builtin

"displaced-alien" "alien" create 20 "displaced-alien?" "alien" create { } define-builtin

FORGET: builtin-predicate
FORGET: register-builtin
FORGET: define-builtin
