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
USE: alien
USE: compiler
USE: errors
USE: files
USE: io-internals
USE: kernel
USE: lists
USE: math
USE: parser
USE: profiler
USE: random
USE: real-math
USE: stack
USE: strings
USE: unparser
USE: vectors
USE: words

[
    [ execute                | " word -- " ]
    [ call                   | " quot -- " ]
    [ ifte                   | " cond true false -- " ]
    [ cons                   | " car cdr -- [ car | cdr ] " ]
    [ car                    | " [ car | cdr ] -- car " ]
    [ cdr                    | " [ car | cdr ] -- cdr " ]
    [ set-car                | " car cons -- " ]
    [ set-cdr                | " cdr cons -- " ]
    [ <vector>               | " capacity -- vector" ]
    [ vector-length          | " vector -- n " ]
    [ set-vector-length      | " n vector -- " ]
    [ vector-nth             | " n vector -- obj " ]
    [ set-vector-nth         | " obj n vector -- " ]
    [ str-length             | " str -- n " ]
    [ str-nth                | " n str -- ch " ]
    [ str-compare            | " str str -- -1/0/1 " ]
    [ str=                   | " str str -- ? " ]
    [ str-hashcode           | " str -- n " ]
    [ index-of*              | " n str/ch str -- n " ]
    [ substring              | " start end str -- str "]
    [ str-reverse            | " str -- str " ]
    [ <sbuf>                 | " capacity -- sbuf " ]
    [ sbuf-length            | " sbuf -- n " ]
    [ set-sbuf-length        | " n sbuf -- " ]
    [ sbuf-nth               | " n sbuf -- ch " ]
    [ set-sbuf-nth           | " ch n sbuf -- " ]
    [ sbuf-append            | " ch/str sbuf -- " ]
    [ sbuf>str               | " sbuf -- str " ]
    [ sbuf-reverse           | " sbuf -- " ]
    [ sbuf-clone             | " sbuf -- sbuf " ]
    [ sbuf=                  | " sbuf sbuf -- ? " ]
    [ sbuf-hashcode          | " sbuf -- n " ]
    [ arithmetic-type        | " n n -- type " ]
    [ number?                | " obj -- ? " ]
    [ >fixnum                | " n -- fixnum " ]
    [ >bignum                | " n -- bignum " ]
    [ >float                 | " n -- float " ]
    [ numerator              | " a/b -- a " ]
    [ denominator            | " a/b -- b " ]
    [ >fraction              | " a/b -- a b " ]
    [ fraction>              | " a b -- a/b " ]
    [ str>float              | " str -- float " ]
    [ unparse-float          | " float -- str " ]
    [ float>bits             | " float -- n " ]
    [ real                   | " #{ re im } -- re " ]
    [ imaginary              | " #{ re im } -- im " ]
    [ >rect                  | " #{ re im } -- re im " ]
    [ rect>                  | " re im -- #{ re im } " ]
    [ fixnum=                | " x y -- ? " ]
    [ fixnum+                | " x y -- x+y " ]
    [ fixnum-                | " x y -- x-y " ]
    [ fixnum*                | " x y -- x*y " ]
    [ fixnum/i               | " x y -- x/y " ]
    [ fixnum/f               | " x y -- x/y " ]
    [ fixnum-mod             | " x y -- x%y " ]
    [ fixnum/mod             | " x y -- x/y x%y " ]
    [ fixnum-bitand          | " x y -- x&y " ]
    [ fixnum-bitor           | " x y -- x|y " ]
    [ fixnum-bitxor          | " x y -- x^y " ]
    [ fixnum-bitnot          | " x -- ~x " ]
    [ fixnum-shift           | " x n -- x<<n" ]
    [ fixnum<                | " x y -- ? " ]
    [ fixnum<=               | " x y -- ? " ]
    [ fixnum>                | " x y -- ? " ]
    [ fixnum>=               | " x y -- ? " ]
    [ bignum=                | " x y -- ? " ]
    [ bignum+                | " x y -- x+y " ]
    [ bignum-                | " x y -- x-y " ]
    [ bignum*                | " x y -- x*y " ]
    [ bignum/i               | " x y -- x/y " ]
    [ bignum/f               | " x y -- x/y " ]
    [ bignum-mod             | " x y -- x%y " ]
    [ bignum/mod             | " x y -- x/y x%y " ]
    [ bignum-bitand          | " x y -- x&y " ]
    [ bignum-bitor           | " x y -- x|y " ]
    [ bignum-bitxor          | " x y -- x^y " ]
    [ bignum-bitnot          | " x -- ~x " ]
    [ bignum-shift           | " x n -- x<<n" ]
    [ bignum<                | " x y -- ? " ]
    [ bignum<=               | " x y -- ? " ]
    [ bignum>                | " x y -- ? " ]
    [ bignum>=               | " x y -- ? " ]
    [ float=                 | " x y -- ? " ]
    [ float+                 | " x y -- x+y " ]
    [ float-                 | " x y -- x-y " ]
    [ float*                 | " x y -- x*y " ]
    [ float/f                | " x y -- x/y " ]
    [ float<                 | " x y -- ? " ]
    [ float<=                | " x y -- ? " ]
    [ float>                 | " x y -- ? " ]
    [ float>=                | " x y -- ? " ]
    [ facos                  | " x -- y " ]
    [ fasin                  | " x -- y " ]
    [ fatan                  | " x -- y " ]
    [ fatan2                 | " x y -- z " ]
    [ fcos                   | " x -- y " ]
    [ fexp                   | " x -- y " ]
    [ fcosh                  | " x -- y " ]
    [ flog                   | " x -- y " ]
    [ fpow                   | " x y -- z " ]
    [ fsin                   | " x -- y " ]
    [ fsinh                  | " x -- y " ]
    [ fsqrt                  | " x -- y " ]
    [ <word>                 | " prim param plist -- word " ]
    [ word-hashcode          | " word -- n " ]
    [ word-xt                | " word -- xt " ]
    [ set-word-xt            | " xt word -- " ]
    [ word-primitive         | " word -- n " ]
    [ set-word-primitive     | " n word -- " ]
    [ word-parameter         | " word -- obj " ]
    [ set-word-parameter     | " obj word -- " ]
    [ word-plist             | " word -- alist" ]
    [ set-word-plist         | " alist word -- " ]
    [ drop                   | " x -- " ]
    [ dup                    | " x -- x x " ]
    [ swap                   | " x y -- y x " ]
    [ over                   | " x y -- x y x " ]
    [ pick                   | " x y z -- x y z x " ]
    [ nip                    | " x y -- y " ]
    [ tuck                   | " x y -- y x y " ]
    [ rot                    | " x y z -- y z x " ]
    [ >r                     | " x -- r:x " ]
    [ r>                     | " r:x -- x " ]
    [ eq?                    | " x y -- ? " ]
    [ getenv                 | " n -- obj " ]
    [ setenv                 | " obj n -- " ]
    [ open-file              | " path r w -- port " ]
    [ stat                   | " path -- [ dir? perm size mtime ] " ]
    [ (directory)            | " path -- list " ]
    [ garbage-collection     | " -- " ]
    [ save-image             | " path -- " ]
    [ datastack              | " -- ds " ]
    [ callstack              | " -- cs " ]
    [ set-datastack          | " ds -- " ]
    [ set-callstack          | " cs -- " ]
    [ exit*                  | " n -- " ]
    [ client-socket          | " host port -- in out " ]
    [ server-socket          | " port -- server " ]
    [ close-port             | " port -- " ]
    [ add-accept-io-task     | " callback server -- " ]
    [ accept-fd              | " server -- host port in out " ]
    [ can-read-line?         | " port -- ? " ]
    [ add-read-line-io-task  | " port callback -- " ]
    [ read-line-fd-8         | " port -- sbuf " ]
    [ can-read-count?        | " n port -- ? " ]
    [ add-read-count-io-task | " n port callback -- " ]
    [ read-count-fd-8        | " n port -- sbuf " ]
    [ can-write?             | " n port -- ? " ]
    [ add-write-io-task      | " port callback -- " ]
    [ write-fd-8             | " ch/str port -- " ]
    [ add-copy-io-task       | " from to callback -- " ]
    [ pending-io-error       | " -- " ]
    [ next-io-task           | " -- callback " ]
    [ room                   | " -- free total " ]
    [ os-env                 | " str -- str " ]
    [ millis                 | " -- n " ]
    [ init-random            | " -- " ]
    [ (random-int)           | " -- n " ]
    [ type                   | " obj -- n " ]
    [ size                   | " obj -- n " ]
    [ call-profiling         | " depth -- " ]
    [ call-count             | " word -- n " ]
    [ set-call-count         | " n word -- " ]
    [ allot-profiling        | " depth -- " ]
    [ allot-count            | " word -- n " ]
    [ set-allot-count        | " n word -- n " ]
    [ dump                   | " obj -- " ]
    [ cwd                    | " -- dir " ]
    [ cd                     | " dir -- " ]
    [ compiled-offset        | " -- ptr " ]
    [ set-compiled-offset    | " ptr -- " ]
    [ set-compiled-cell      | " n ptr -- " ]
    [ set-compiled-byte      | " n ptr -- " ]
    [ literal-top            | " -- ptr " ]
    [ set-literal-top        | " ptr -- " ]
    [ address                | " obj -- ptr " ]
    [ dlopen                 | " path -- dll " ]
    [ dlsym                  | " name dll -- ptr " ]
    [ dlsym-self             | " name -- ptr " ]
    [ dlclose                | " dll -- " ]
    [ <alien>                | " ptr len -- alien " ]
    [ <local-alien>          | " len -- alien " ]
    [ alien-cell             | " alien off -- n " ]
    [ set-alien-cell         | " n alien off -- " ]
    [ alien-4                | " alien off -- n " ]
    [ set-alien-4            | " n alien off -- " ]
    [ alien-2                | " alien off -- n " ]
    [ set-alien-2            | " n alien off -- " ]
    [ alien-1                | " alien off -- n " ]
    [ set-alien-1            | " n alien off -- " ]
    [ heap-stats             | " -- instances bytes " ]
    [ throw                  | " error -- " ]
] [
    unswons "stack-effect" set-word-property
] each
