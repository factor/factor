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

IN: cross-compiler
USE: arithmetic
USE: kernel
USE: lists
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

IN: arithmetic
DEFER: number=
DEFER: >integer
DEFER: /i

IN: kernel
DEFER: getenv
DEFER: setenv
DEFER: save-image
DEFER: room
DEFER: os-env
DEFER: type-of
DEFER: size-of

IN: strings
DEFER: str=
DEFER: str-hashcode
DEFER: sbuf=
DEFER: clone-sbuf

IN: io-internals
DEFER: port?
DEFER: open-file
DEFER: server-socket
DEFER: close-fd
DEFER: add-accept-io-task
DEFER: accept-fd
DEFER: can-read-line?
DEFER: add-read-line-io-task
DEFER: read-line-fd-8
DEFER: can-write?
DEFER: add-write-io-task
DEFER: write-fd-8
DEFER: next-io-task

IN: parser
DEFER: str>float

IN: random
DEFER: init-random
DEFER: (random-int)

IN: words
DEFER: <word>
DEFER: word-primitive
DEFER: set-word-primitive
DEFER: word-parameter
DEFER: set-word-parameter
DEFER: word-plist
DEFER: set-word-plist

IN: unparser
DEFER: unparse-float

IN: cross-compiler

: primitives, ( -- )
    1 [
        execute
        call
        ifte
        cons?
        cons
        car
        cdr
        set-car
        set-cdr
        vector?
        <vector>
        vector-length
        set-vector-length
        vector-nth
        set-vector-nth
        string?
        str-length
        str-nth
        str-compare
        str=
        str-hashcode
        index-of*
        substring
        sbuf?
        <sbuf>
        sbuf-length
        set-sbuf-length
        sbuf-nth
        set-sbuf-nth
        sbuf-append
        sbuf>str
        clone-sbuf
        sbuf=
        number?
        >fixnum
        >bignum
        >integer
        >float
        number=
        fixnum?
        bignum?
        ratio?
        numerator
        denominator
        float?
        str>float
        unparse-float
        float>bits
        complex?
        real
        imaginary
        >rect
        rect>
        +
        -
        *
        /i
        /f
        /
        mod
        /mod
        bitand
        bitor
        bitxor
        bitnot
        shift<
        shift>
        <
        <=
        >
        >=
        gcd
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
        word?
        <word>
        word-primitive
        set-word-primitive
        word-parameter
        set-word-parameter
        word-plist
        set-word-plist
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
        garbage-collection
        save-image
        datastack
        callstack
        set-datastack
        set-callstack
        port?
        exit*
        server-socket
        close-fd
        add-accept-io-task
        accept-fd
        can-read-line?
        add-read-line-io-task
        read-line-fd-8
        can-write?
        add-write-io-task
        write-fd-8
        next-io-task
        room
        os-env
        millis
        init-random
        (random-int)
        type-of
        size-of
    ] [
        swap succ tuck primitive,
    ] each drop ;

: version, ( -- )
    "version" [ "kernel" ] search version unit compound, ;

: make-image ( name -- )
    #! Make an image for the C interpreter.
    [
        "/library/platform/native/boot.factor" run-resource
    ] with-image

    swap write-image ;

: make-images ( -- )
    "big-endian" off "factor.image.le" make-image
    "big-endian" on  "factor.image.be" make-image ;
