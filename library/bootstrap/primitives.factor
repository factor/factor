! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: kernel lists math memory namespaces parser words vectors
hashtables generic alien assembler compiler errors files generic
io-internals kernel kernel-internals lists math math-internals
parser profiler random strings unparser vectors words
hashtables ;

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab clone
"generic" vocab clone

! These symbol needs the same hashcode in the target as in the
! host.
vocabularies
classes

<namespace> vocabularies set
<namespace> classes set

vocabularies get [
    reveal
    reveal
    "generic" set
    "syntax" set
] bind

! We cannot simply copy the delegate generic with all its
! methods. Rather we must create a new empty generic.
"delegate" [ "generic" ] search forget
[ single-combination ] \ GENERIC: "delegate" "generic" create define-generic

2 [
    [ "execute" "words"                       " word -- " ]
    [ "call" "kernel"                         [ [ general-list ] [ ] ] ]
    [ "ifte" "kernel"                         [ [ object general-list general-list ] [ ] ] ]
    [ "cons" "lists"                          [ [ object object ] [ cons ] ] ]
    [ "<vector>" "vectors"                    [ [ integer ] [ vector ] ] ]
    [ "string-nth" "strings"                  [ [ integer string ] [ integer ] ] ]
    [ "string-compare" "strings"              [ [ string string ] [ integer ] ] ]
    [ "string=" "strings"                     [ [ string string ] [ boolean ] ] ]
    [ "index-of*" "strings"                   [ [ integer string text ] [ integer ] ] ]
    [ "substring" "strings"                   [ [ integer integer string ] [ string ] ] ]
    [ "<sbuf>" "strings"                      [ [ integer ] [ sbuf ] ] ]
    [ "sbuf-length" "strings"                 [ [ sbuf ] [ integer ] ] ]
    [ "set-sbuf-length" "strings"             [ [ integer sbuf ] [ ] ] ]
    [ "sbuf-nth" "strings"                    [ [ integer sbuf ] [ integer ] ] ]
    [ "set-sbuf-nth" "strings"                [ [ integer integer sbuf ] [ ] ] ]
    [ "sbuf-append" "strings"                 [ [ text sbuf ] [ ] ] ]
    [ "sbuf>string" "strings"                 [ [ sbuf ] [ string ] ] ]
    [ "sbuf-clone" "strings"                  [ [ sbuf ] [ sbuf ] ] ]
    [ "sbuf=" "strings"                       [ [ sbuf sbuf ] [ boolean ] ] ]
    [ "arithmetic-type" "math-internals"      [ [ object object ] [ object object fixnum ] ] ]
    [ ">fixnum" "math"                        [ [ number ] [ fixnum ] ] ]
    [ ">bignum" "math"                        [ [ number ] [ bignum ] ] ]
    [ ">float" "math"                         [ [ number ] [ float ] ] ]
    [ "(fraction>)" "math-internals"          [ [ integer integer ] [ rational ] ] ]
    [ "str>float" "parser"                    [ [ string ] [ float ] ] ]
    [ "(unparse-float)" "unparser"            [ [ float ] [ string ] ] ]
    [ "<complex>" "math-internals"            [ [ real real ] [ number ] ] ]
    [ "fixnum+" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] ]
    [ "fixnum-" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] ]
    [ "fixnum*" "math-internals"              [ [ fixnum fixnum ] [ integer ] ] ]
    [ "fixnum/i" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] ]
    [ "fixnum/f" "math-internals"             [ [ fixnum fixnum ] [ integer ] ] ]
    [ "fixnum-mod" "math-internals"           [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ "fixnum/mod" "math-internals"           [ [ fixnum fixnum ] [ integer fixnum ] ] ]
    [ "fixnum-bitand" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ "fixnum-bitor" "math-internals"         [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ "fixnum-bitxor" "math-internals"        [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ "fixnum-bitnot" "math-internals"        [ [ fixnum ] [ fixnum ] ] ]
    [ "fixnum-shift" "math-internals"         [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ "fixnum<" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] ]
    [ "fixnum<=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] ]
    [ "fixnum>" "math-internals"              [ [ fixnum fixnum ] [ boolean ] ] ]
    [ "fixnum>=" "math-internals"             [ [ fixnum fixnum ] [ boolean ] ] ]
    [ "bignum=" "math-internals"              [ [ bignum bignum ] [ boolean ] ] ]
    [ "bignum+" "math-internals"              [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum-" "math-internals"              [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum*" "math-internals"              [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum/i" "math-internals"             [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum/f" "math-internals"             [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum-mod" "math-internals"           [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum/mod" "math-internals"           [ [ bignum bignum ] [ bignum bignum ] ] ]
    [ "bignum-bitand" "math-internals"        [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum-bitor" "math-internals"         [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum-bitxor" "math-internals"        [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum-bitnot" "math-internals"        [ [ bignum ] [ bignum ] ] ]
    [ "bignum-shift" "math-internals"         [ [ bignum bignum ] [ bignum ] ] ]
    [ "bignum<" "math-internals"              [ [ bignum bignum ] [ boolean ] ] ]
    [ "bignum<=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] ]
    [ "bignum>" "math-internals"              [ [ bignum bignum ] [ boolean ] ] ]
    [ "bignum>=" "math-internals"             [ [ bignum bignum ] [ boolean ] ] ]
    [ "float=" "math-internals"               [ [ bignum bignum ] [ boolean ] ] ]
    [ "float+" "math-internals"               [ [ float float ] [ float ] ] ]
    [ "float-" "math-internals"               [ [ float float ] [ float ] ] ]
    [ "float*" "math-internals"               [ [ float float ] [ float ] ] ]
    [ "float/f" "math-internals"              [ [ float float ] [ float ] ] ]
    [ "float<" "math-internals"               [ [ float float ] [ boolean ] ] ]
    [ "float<=" "math-internals"              [ [ float float ] [ boolean ] ] ]
    [ "float>" "math-internals"               [ [ float float ] [ boolean ] ] ]
    [ "float>=" "math-internals"              [ [ float float ] [ boolean ] ] ]
    [ "facos" "math-internals"                [ [ real ] [ float ] ] ]
    [ "fasin" "math-internals"                [ [ real ] [ float ] ] ]
    [ "fatan" "math-internals"                [ [ real ] [ float ] ] ]
    [ "fatan2" "math-internals"               [ [ real real ] [ float ] ] ]
    [ "fcos" "math-internals"                 [ [ real ] [ float ] ] ]
    [ "fexp" "math-internals"                 [ [ real ] [ float ] ] ]
    [ "fcosh" "math-internals"                [ [ real ] [ float ] ] ]
    [ "flog" "math-internals"                 [ [ real ] [ float ] ] ]
    [ "fpow" "math-internals"                 [ [ real real ] [ float ] ] ]
    [ "fsin" "math-internals"                 [ [ real ] [ float ] ] ]
    [ "fsinh" "math-internals"                [ [ real ] [ float ] ] ]
    [ "fsqrt" "math-internals"                [ [ real ] [ float ] ] ]
    [ "<word>" "words"                        [ [ ] [ word ] ] ]
    [ "update-xt" "words"                     [ [ word ] [ ] ] ]
    [ "call-profiling" "profiler"             [ [ integer ] [ ] ] ]
    [ "allot-profiling" "profiler"            [ [ integer ] [ ] ] ]
    [ "compiled?" "words"                     [ [ word ] [ boolean ] ] ]
    [ "drop" "kernel"                         [ [ object ] [ ] ] ]
    [ "dup" "kernel"                          [ [ object ] [ object object ] ] ]
    [ "swap" "kernel"                         [ [ object object ] [ object object ] ] ]
    [ "over" "kernel"                         [ [ object object ] [ object object object ] ] ]
    [ "pick" "kernel"                         [ [ object object object ] [ object object object object ] ] ]
    [ ">r" "kernel"                           [ [ object ] [ ] ] ]
    [ "r>" "kernel"                           [ [ ] [ object ] ] ]
    [ "eq?" "kernel"                          [ [ object object ] [ boolean ] ] ]
    [ "getenv" "kernel-internals"             [ [ fixnum ] [ object ] ] ]
    [ "setenv" "kernel-internals"             [ [ object fixnum ] [ ] ] ]
    [ "open-file" "io-internals"              [ [ string object object ] [ port ] ] ]
    [ "stat" "files"                          [ [ string ] [ general-list ] ] ]
    [ "(directory)" "files"                   [ [ string ] [ general-list ] ] ]
    [ "garbage-collection" "memory"           [ [ ] [ ] ] ]
    [ "gc-time" "memory"                      [ [ string ] [ ] ] ]
    [ "save-image" "memory"                   [ [ string ] [ ] ] ]
    [ "datastack" "kernel"                    " -- ds "          ]
    [ "callstack" "kernel"                    " -- cs "          ]
    [ "set-datastack" "kernel"                " ds -- "          ]
    [ "set-callstack" "kernel"                " cs -- "          ]
    [ "exit" "kernel"                         [ [ integer ] [ ] ] ]
    [ "client-socket" "io-internals"          [ [ string integer ] [ port port ] ] ]
    [ "server-socket" "io-internals"          [ [ integer ] [ port ] ] ]
    [ "close-port" "io-internals"             [ [ port ] [ ] ] ]
    [ "add-accept-io-task" "io-internals"     [ [ port general-list ] [ ] ] ]
    [ "accept-fd" "io-internals"              [ [ port ] [ string integer port port ] ] ]
    [ "can-read-line?" "io-internals"         [ [ port ] [ boolean ] ] ]
    [ "add-read-line-io-task" "io-internals"  [ [ port general-list ] [ ] ] ]
    [ "read-line-fd-8" "io-internals"         [ [ port ] [ sbuf ] ] ]
    [ "can-read-count?" "io-internals"        [ [ integer port ] [ boolean ] ] ]
    [ "add-read-count-io-task" "io-internals" [ [ integer port general-list ] [ ] ] ]
    [ "read-count-fd-8" "io-internals"        [ [ integer port ] [ sbuf ] ] ]
    [ "can-write?" "io-internals"             [ [ integer port ] [ boolean ] ] ]
    [ "add-write-io-task" "io-internals"      [ [ port general-list ] [ ] ] ]
    [ "write-fd-8" "io-internals"             [ [ text port ] [ ] ] ]
    [ "add-copy-io-task" "io-internals"       [ [ port port general-list ] [ ] ] ]
    [ "pending-io-error" "io-internals"       [ [ ] [ ] ] ]
    [ "next-io-task" "io-internals"           [ [ ] [ general-list ] ] ]
    [ "room" "memory"                         [ [ ] [ integer integer integer integer ] ] ]
    [ "os-env" "kernel"                       [ [ string ] [ object ] ] ]
    [ "millis" "kernel"                       [ [ ] [ integer ] ] ]
    [ "init-random" "random"                  [ [ ] [ ] ] ]
    [ "(random-int)" "random"                 [ [ ] [ integer ] ] ]
    [ "type" "kernel"                         [ [ object ] [ fixnum ] ] ]
    [ "cwd" "files"                           [ [ ] [ string ] ] ]
    [ "cd" "files"                            [ [ string ] [ ] ] ]
    [ "compiled-offset" "assembler"           [ [ ] [ integer ] ] ]
    [ "set-compiled-offset" "assembler"       [ [ integer ] [ ] ] ]
    [ "literal-top" "assembler"               [ [ ] [ integer ] ] ]
    [ "set-literal-top" "assembler"           [ [ integer ] [ ] ] ]
    [ "address" "memory"                      [ [ object ] [ integer ] ] ]
    [ "dlopen" "alien"                        [ [ string ] [ dll ] ] ]
    [ "dlsym" "alien"                         [ [ string object ] [ integer ] ] ]
    [ "dlclose" "alien"                       [ [ dll ] [ ] ] ]
    [ "<alien>" "alien"                       [ [ integer ] [ alien ] ] ]
    [ "<local-alien>" "alien"                 [ [ integer ] [ alien ] ] ]
    [ "alien-cell" "alien"                    [ [ alien integer ] [ integer ] ] ]
    [ "set-alien-cell" "alien"                [ [ integer alien integer ] [ ] ] ]
    [ "alien-4" "alien"                       [ [ alien integer ] [ integer ] ] ]
    [ "set-alien-4" "alien"                   [ [ integer alien integer ] [ ] ] ]
    [ "alien-2" "alien"                       [ [ alien integer ] [ fixnum ] ] ]
    [ "set-alien-2" "alien"                   [ [ integer alien integer ] [ ] ] ]
    [ "alien-1" "alien"                       [ [ alien integer ] [ fixnum ] ] ]
    [ "set-alien-1" "alien"                   [ [ integer alien integer ] [ ] ] ]
    [ "throw" "errors"                        [ [ object ] [ ] ] ]
    [ "string>memory" "kernel-internals"      [ [ string integer ] [ ] ] ]
    [ "memory>string" "kernel-internals"      [ [ integer integer ] [ string ] ] ]
    [ "local-alien?" "alien"                  [ [ alien ] [ object ] ] ]
    [ "alien-address" "alien"                 [ [ alien ] [ integer ] ] ]
    [ "slot" "kernel-internals"               [ [ object fixnum ] [ object ] ] ]
    [ "set-slot" "kernel-internals"           [ [ object object fixnum ] [ ] ] ]
    [ "integer-slot" "kernel-internals"       [ [ object fixnum ] [ integer ] ] ]
    [ "set-integer-slot" "kernel-internals"   [ [ integer object fixnum ] [ ] ] ]
    [ "grow-array" "kernel-internals"         [ [ integer array ] [ object ] ] ]
    [ "<hashtable>" "hashtables"              [ [ number ] [ hashtable ] ] ]
    [ "<array>" "kernel-internals"            [ [ number ] [ array ] ] ]
    [ "<tuple>" "kernel-internals"            [ [ number ] [ tuple ] ] ]
    [ "begin-scan" "memory"                   [ [ ] [ ] ] ]
    [ "next-object" "memory"                  [ [ ] [ object ] ] ]
    [ "end-scan" "memory"                     [ [ ] [ ] ] ]
    [ "size" "memory"                         [ [ object ] [ fixnum ] ] ]
    [ "die" "kernel"                          [ [ ] [ ] ] ]
    [ "flush-icache" "assembler"              f ]
] [
    3unlist >r create >r 1 + r> 2dup swap f define r>
    dup string? [
        "stack-effect" set-word-prop
    ] [
        "infer-effect" set-word-prop
    ] ifte
] each drop
