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

USE: combinators
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: real-math
USE: stack
USE: stdio
USE: streams
USE: strings
USE: vectors
USE: vectors
USE: words

IN: alien
DEFER: dlopen
DEFER: dlsym
DEFER: dlsym-self
DEFER: dlclose
DEFER: <alien>
DEFER: <local-alien>
DEFER: alien-cell
DEFER: set-alien-cell
DEFER: alien-4
DEFER: set-alien-4
DEFER: alien-2
DEFER: set-alien-2
DEFER: alien-1
DEFER: set-alien-1

IN: compiler
DEFER: set-compiled-byte
DEFER: set-compiled-cell
DEFER: compiled-offset
DEFER: set-compiled-offset
DEFER: literal-top
DEFER: set-literal-top

IN: kernel
DEFER: gc-time
DEFER: getenv
DEFER: setenv
DEFER: save-image
DEFER: room
DEFER: os-env
DEFER: type
DEFER: size
DEFER: address
DEFER: heap-stats

IN: strings
DEFER: str=
DEFER: str-hashcode
DEFER: sbuf=
DEFER: sbuf-hashcode
DEFER: sbuf-clone

IN: files
DEFER: stat
DEFER: (directory)
DEFER: cwd
DEFER: cd

IN: io-internals
DEFER: open-file
DEFER: client-socket
DEFER: server-socket
DEFER: close-port
DEFER: add-accept-io-task
DEFER: accept-fd
DEFER: can-read-line?
DEFER: add-read-line-io-task
DEFER: read-line-fd-8
DEFER: can-read-count?
DEFER: add-read-count-io-task
DEFER: read-count-fd-8
DEFER: can-write?
DEFER: add-write-io-task
DEFER: write-fd-8
DEFER: add-copy-io-task
DEFER: pending-io-error
DEFER: next-io-task

IN: math
DEFER: arithmetic-type
DEFER: >fraction
DEFER: fraction>
DEFER: fixnum=
DEFER: fixnum+
DEFER: fixnum-
DEFER: fixnum*
DEFER: fixnum/i
DEFER: fixnum/f
DEFER: fixnum-mod
DEFER: fixnum/mod
DEFER: fixnum-bitand
DEFER: fixnum-bitor
DEFER: fixnum-bitxor
DEFER: fixnum-bitnot
DEFER: fixnum-shift
DEFER: fixnum<
DEFER: fixnum<=
DEFER: fixnum>
DEFER: fixnum>=
DEFER: bignum=
DEFER: bignum+
DEFER: bignum-
DEFER: bignum*
DEFER: bignum/i
DEFER: bignum/f
DEFER: bignum-mod
DEFER: bignum/mod
DEFER: bignum-bitand
DEFER: bignum-bitor
DEFER: bignum-bitxor
DEFER: bignum-bitnot
DEFER: bignum-shift
DEFER: bignum<
DEFER: bignum<=
DEFER: bignum>
DEFER: bignum>=
DEFER: float=
DEFER: float+
DEFER: float-
DEFER: float*
DEFER: float/f
DEFER: float<
DEFER: float<=
DEFER: float>
DEFER: float>=

IN: parser
DEFER: str>float

IN: profiler
DEFER: call-profiling
DEFER: call-count
DEFER: set-call-count
DEFER: allot-profiling
DEFER: allot-count
DEFER: set-allot-count

IN: random
DEFER: init-random
DEFER: (random-int)

IN: words
DEFER: <word>
DEFER: word-hashcode
DEFER: word-xt
DEFER: set-word-xt
DEFER: word-primitive
DEFER: set-word-primitive
DEFER: word-parameter
DEFER: set-word-parameter
DEFER: word-plist
DEFER: set-word-plist
DEFER: compiled?

IN: unparser
DEFER: (unparse-float)

IN: image

: primitives, ( -- )
    2 [
        execute
        call
        ifte
        cons
        car
        cdr
        <vector>
        vector-length
        set-vector-length
        vector-nth
        set-vector-nth
        str-length
        str-nth
        str-compare
        str=
        str-hashcode
        index-of*
        substring
        str-reverse
        <sbuf>
        sbuf-length
        set-sbuf-length
        sbuf-nth
        set-sbuf-nth
        sbuf-append
        sbuf>str
        sbuf-reverse
        sbuf-clone
        sbuf=
        sbuf-hashcode
        arithmetic-type
        number?
        >fixnum
        >bignum
        >float
        numerator
        denominator
        fraction>
        str>float
        (unparse-float)
        float>bits
        real
        imaginary
        rect>
        fixnum=
        fixnum+
        fixnum-
        fixnum*
        fixnum/i
        fixnum/f
        fixnum-mod
        fixnum/mod
        fixnum-bitand
        fixnum-bitor
        fixnum-bitxor
        fixnum-bitnot
        fixnum-shift
        fixnum<
        fixnum<=
        fixnum>
        fixnum>=
        bignum=
        bignum+
        bignum-
        bignum*
        bignum/i
        bignum/f
        bignum-mod
        bignum/mod
        bignum-bitand
        bignum-bitor
        bignum-bitxor
        bignum-bitnot
        bignum-shift
        bignum<
        bignum<=
        bignum>
        bignum>=
        float=
        float+
        float-
        float*
        float/f
        float<
        float<=
        float>
        float>=
        facos
        fasin
        fatan
        fatan2
        fcos
        fexp
        fcosh
        flog
        fpow
        fsin
        fsinh
        fsqrt
        <word>
        word-hashcode
        word-xt
        set-word-xt
        word-primitive
        set-word-primitive
        word-parameter
        set-word-parameter
        word-plist
        set-word-plist
        call-profiling
        call-count
        set-call-count
        allot-profiling
        allot-count
        set-allot-count
        compiled?
        drop
        dup
        swap
        over
        pick
        nip
        tuck
        rot
        >r
        r>
        eq?
        getenv
        setenv
        open-file
        stat
        (directory)
        garbage-collection
        gc-time
        save-image
        datastack
        callstack
        set-datastack
        set-callstack
        exit*
        client-socket
        server-socket
        close-port
        add-accept-io-task
        accept-fd
        can-read-line?
        add-read-line-io-task
        read-line-fd-8
        can-read-count?
        add-read-count-io-task
        read-count-fd-8
        can-write?
        add-write-io-task
        write-fd-8
        add-copy-io-task
        pending-io-error
        next-io-task
        room
        os-env
        millis
        init-random
        (random-int)
        type
        size
        cwd
        cd
        compiled-offset
        set-compiled-offset
        set-compiled-cell
        set-compiled-byte
        literal-top
        set-literal-top
        address
        dlopen
        dlsym
        dlsym-self
        dlclose
        <alien>
        <local-alien>
        alien-cell
        set-alien-cell
        alien-4
        set-alien-4
        alien-2
        set-alien-2
        alien-1
        set-alien-1
        heap-stats
        throw
    ] [
        swap succ tuck f define,
    ] each drop ;

: make-image ( name -- )
    #! Make an image for the C interpreter.
    [
        "/library/bootstrap/boot.factor" run-resource
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

: cross-compile-resource ( resource -- )
    [
        ! Change behavior of ; and SYMBOL:
        [ define, ] "define-hook" set
        run-resource
    ] with-scope ;
