! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: image
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: words
USE: vectors
USE: hashtables

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab
"generic" vocab

! This symbol needs the same hashcode in the target as in the
! host.
vocabularies

<namespace> vocabularies set
vocabularies get [
    reveal
    "generic" set
    "syntax" set
] bind

2 [
    [ "words" | "execute" ]
    [ "kernel" | "call" ]
    [ "kernel" | "ifte" ]
    [ "lists" | "cons" ]
    [ "lists" | "car" ]
    [ "lists" | "cdr" ]
    [ "vectors" | "<vector>" ]
    [ "vectors" | "vector-length" ]
    [ "vectors" | "set-vector-length" ]
    [ "vectors" | "vector-nth" ]
    [ "vectors" | "set-vector-nth" ]
    [ "strings" | "str-length" ]
    [ "strings" | "str-nth" ]
    [ "strings" | "str-compare" ]
    [ "strings" | "str=" ]
    [ "strings" | "str-hashcode" ]
    [ "strings" | "index-of*" ]
    [ "strings" | "substring" ]
    [ "strings" | "str-reverse" ]
    [ "strings" | "<sbuf>" ]
    [ "strings" | "sbuf-length" ]
    [ "strings" | "set-sbuf-length" ]
    [ "strings" | "sbuf-nth" ]
    [ "strings" | "set-sbuf-nth" ]
    [ "strings" | "sbuf-append" ]
    [ "strings" | "sbuf>str" ]
    [ "strings" | "sbuf-reverse" ]
    [ "strings" | "sbuf-clone" ]
    [ "strings" | "sbuf=" ]
    [ "strings" | "sbuf-hashcode" ]
    [ "math-internals" | "arithmetic-type" ]
    [ "math" | "number?" ]
    [ "math" | ">fixnum" ]
    [ "math" | ">bignum" ]
    [ "math" | ">float" ]
    [ "math" | "numerator" ]
    [ "math" | "denominator" ]
    [ "math" | "fraction>" ]
    [ "parser" | "str>float" ]
    [ "unparser" | "(unparse-float)" ]
    [ "math" | "float>bits" ]
    [ "math" | "real" ]
    [ "math" | "imaginary" ]
    [ "math" | "rect>" ]
    [ "math-internals" | "fixnum=" ]
    [ "math-internals" | "fixnum+" ]
    [ "math-internals" | "fixnum-" ]
    [ "math-internals" | "fixnum*" ]
    [ "math-internals" | "fixnum/i" ]
    [ "math-internals" | "fixnum/f" ]
    [ "math-internals" | "fixnum-mod" ]
    [ "math-internals" | "fixnum/mod" ]
    [ "math-internals" | "fixnum-bitand" ]
    [ "math-internals" | "fixnum-bitor" ]
    [ "math-internals" | "fixnum-bitxor" ]
    [ "math-internals" | "fixnum-bitnot" ]
    [ "math-internals" | "fixnum-shift" ]
    [ "math-internals" | "fixnum<" ]
    [ "math-internals" | "fixnum<=" ]
    [ "math-internals" | "fixnum>" ]
    [ "math-internals" | "fixnum>=" ]
    [ "math-internals" | "bignum=" ]
    [ "math-internals" | "bignum+" ]
    [ "math-internals" | "bignum-" ]
    [ "math-internals" | "bignum*" ]
    [ "math-internals" | "bignum/i" ]
    [ "math-internals" | "bignum/f" ]
    [ "math-internals" | "bignum-mod" ]
    [ "math-internals" | "bignum/mod" ]
    [ "math-internals" | "bignum-bitand" ]
    [ "math-internals" | "bignum-bitor" ]
    [ "math-internals" | "bignum-bitxor" ]
    [ "math-internals" | "bignum-bitnot" ]
    [ "math-internals" | "bignum-shift" ]
    [ "math-internals" | "bignum<" ]
    [ "math-internals" | "bignum<=" ]
    [ "math-internals" | "bignum>" ]
    [ "math-internals" | "bignum>=" ]
    [ "math-internals" | "float=" ]
    [ "math-internals" | "float+" ]
    [ "math-internals" | "float-" ]
    [ "math-internals" | "float*" ]
    [ "math-internals" | "float/f" ]
    [ "math-internals" | "float<" ]
    [ "math-internals" | "float<=" ]
    [ "math-internals" | "float>" ]
    [ "math-internals" | "float>=" ]
    [ "math-internals" | "facos" ]
    [ "math-internals" | "fasin" ]
    [ "math-internals" | "fatan" ]
    [ "math-internals" | "fatan2" ]
    [ "math-internals" | "fcos" ]
    [ "math-internals" | "fexp" ]
    [ "math-internals" | "fcosh" ]
    [ "math-internals" | "flog" ]
    [ "math-internals" | "fpow" ]
    [ "math-internals" | "fsin" ]
    [ "math-internals" | "fsinh" ]
    [ "math-internals" | "fsqrt" ]
    [ "words" | "<word>" ]
    [ "words" | "word-hashcode" ]
    [ "words" | "word-xt" ]
    [ "words" | "set-word-xt" ]
    [ "words" | "word-primitive" ]
    [ "words" | "set-word-primitive" ]
    [ "words" | "word-parameter" ]
    [ "words" | "set-word-parameter" ]
    [ "words" | "word-plist" ]
    [ "words" | "set-word-plist" ]
    [ "profiler" | "call-profiling" ]
    [ "profiler" | "call-count" ]
    [ "profiler" | "set-call-count" ]
    [ "profiler" | "allot-profiling" ]
    [ "profiler" | "allot-count" ]
    [ "profiler" | "set-allot-count" ]
    [ "words" | "compiled?" ]
    [ "kernel" | "drop" ]
    [ "kernel" | "dup" ]
    [ "kernel" | "swap" ]
    [ "kernel" | "over" ]
    [ "kernel" | "pick" ]
    [ "kernel" | ">r" ]
    [ "kernel" | "r>" ]
    [ "kernel" | "eq?" ]
    [ "kernel" | "getenv" ]
    [ "kernel" | "setenv" ]
    [ "io-internals" | "open-file" ]
    [ "files" | "stat" ]
    [ "files" | "(directory)" ]
    [ "kernel" | "garbage-collection" ]
    [ "kernel" | "gc-time" ]
    [ "kernel" | "save-image" ]
    [ "kernel" | "datastack" ]
    [ "kernel" | "callstack" ]
    [ "kernel" | "set-datastack" ]
    [ "kernel" | "set-callstack" ]
    [ "kernel" | "exit*" ]
    [ "io-internals" | "client-socket" ]
    [ "io-internals" | "server-socket" ]
    [ "io-internals" | "close-port" ]
    [ "io-internals" | "add-accept-io-task" ]
    [ "io-internals" | "accept-fd" ]
    [ "io-internals" | "can-read-line?" ]
    [ "io-internals" | "add-read-line-io-task" ]
    [ "io-internals" | "read-line-fd-8" ]
    [ "io-internals" | "can-read-count?" ]
    [ "io-internals" | "add-read-count-io-task" ]
    [ "io-internals" | "read-count-fd-8" ]
    [ "io-internals" | "can-write?" ]
    [ "io-internals" | "add-write-io-task" ]
    [ "io-internals" | "write-fd-8" ]
    [ "io-internals" | "add-copy-io-task" ]
    [ "io-internals" | "pending-io-error" ]
    [ "io-internals" | "next-io-task" ]
    [ "kernel" | "room" ]
    [ "kernel" | "os-env" ]
    [ "kernel" | "millis" ]
    [ "random" | "init-random" ]
    [ "random" | "(random-int)" ]
    [ "kernel" | "type" ]
    [ "kernel" | "size" ]
    [ "files" | "cwd" ]
    [ "files" | "cd" ]
    [ "compiler" | "compiled-offset" ]
    [ "compiler" | "set-compiled-offset" ]
    [ "compiler" | "set-compiled-cell" ]
    [ "compiler" | "set-compiled-byte" ]
    [ "compiler" | "literal-top" ]
    [ "compiler" | "set-literal-top" ]
    [ "kernel" | "address" ]
    [ "alien" | "dlopen" ]
    [ "alien" | "dlsym" ]
    [ "alien" | "dlsym-self" ]
    [ "alien" | "dlclose" ]
    [ "alien" | "<alien>" ]
    [ "alien" | "<local-alien>" ]
    [ "alien" | "alien-cell" ]
    [ "alien" | "set-alien-cell" ]
    [ "alien" | "alien-4" ]
    [ "alien" | "set-alien-4" ]
    [ "alien" | "alien-2" ]
    [ "alien" | "set-alien-2" ]
    [ "alien" | "alien-1" ]
    [ "alien" | "set-alien-1" ]
    [ "kernel" | "heap-stats" ]
    [ "errors" | "throw" ]
] [
    unswons create swap succ [ f define ] keep
] each drop
