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
    [ execute                " word -- "                          f ]
    [ call                   " quot -- "                          [ 1 | 0 ] ]
    [ ifte                   " cond true false -- "               [ 3 | 0 ] ]
    [ cons                   " car cdr -- [ car | cdr ] "         [ 2 | 1 ] ]
    [ car                    " [ car | cdr ] -- car "             [ 1 | 1 ] ]
    [ cdr                    " [ car | cdr ] -- cdr "             [ 1 | 1 ] ]
    [ <vector>               " capacity -- vector"                [ 1 | 1 ] ]
    [ vector-length          " vector -- n "                      [ 1 | 1 ] ]
    [ set-vector-length      " n vector -- "                      [ 2 | 0 ] ]
    [ vector-nth             " n vector -- obj "                  [ 2 | 1 ] ]
    [ set-vector-nth         " obj n vector -- "                  [ 3 | 0 ] ]
    [ str-length             " str -- n "                         [ 1 | 1 ] ]
    [ str-nth                " n str -- ch "                      [ 2 | 1 ] ]
    [ str-compare            " str str -- -1/0/1 "                [ 2 | 1 ] ]
    [ str=                   " str str -- ? "                     [ 2 | 1 ] ]
    [ str-hashcode           " str -- n "                         [ 1 | 1 ] ]
    [ index-of*              " n str/ch str -- n "                [ 3 | 1 ] ]
    [ substring              " start end str -- str "             [ 3 | 1 ] ]
    [ str-reverse            " str -- str "                       [ 1 | 1 ] ]
    [ <sbuf>                 " capacity -- sbuf "                 [ 1 | 1 ] ]
    [ sbuf-length            " sbuf -- n "                        [ 1 | 1 ] ]
    [ set-sbuf-length        " n sbuf -- "                        [ 2 | 1 ] ]
    [ sbuf-nth               " n sbuf -- ch "                     [ 2 | 1 ] ]
    [ set-sbuf-nth           " ch n sbuf -- "                     [ 3 | 0 ] ]
    [ sbuf-append            " ch/str sbuf -- "                   [ 2 | 1 ] ]
    [ sbuf>str               " sbuf -- str "                      [ 1 | 1 ] ]
    [ sbuf-reverse           " sbuf -- "                          [ 1 | 0 ] ]
    [ sbuf-clone             " sbuf -- sbuf "                     [ 1 | 1 ] ]
    [ sbuf=                  " sbuf sbuf -- ? "                   [ 2 | 1 ] ]
    [ sbuf-hashcode          " sbuf -- n "                        [ 1 | 1 ] ]
    [ arithmetic-type        " n n -- type "                      [ 2 | 1 ] ]
    [ number?                " obj -- ? "                         [ 1 | 1 ] ]
    [ >fixnum                " n -- fixnum "                      [ 1 | 1 ] ]
    [ >bignum                " n -- bignum "                      [ 1 | 1 ] ]
    [ >float                 " n -- float "                       [ 1 | 1 ] ]
    [ numerator              " a/b -- a "                         [ 1 | 1 ] ]
    [ denominator            " a/b -- b "                         [ 1 | 1 ] ]
    [ fraction>              " a b -- a/b "                       [ 1 | 1 ] ]
    [ str>float              " str -- float "                     [ 1 | 1 ] ]
    [ unparse-float          " float -- str "                     [ 1 | 1 ] ]
    [ float>bits             " float -- n "                       [ 1 | 1 ] ]
    [ real                   " #{ re im } -- re "                 [ 1 | 1 ] ]
    [ imaginary              " #{ re im } -- im "                 [ 1 | 1 ] ]
    [ rect>                  " re im -- #{ re im } "              [ 2 | 1 ] ]
    [ fixnum=                " x y -- ? "                         [ 2 | 1 ] ]
    [ fixnum+                " x y -- x+y "                       [ 2 | 1 ] ]
    [ fixnum-                " x y -- x-y "                       [ 2 | 1 ] ]
    [ fixnum*                " x y -- x*y "                       [ 2 | 1 ] ]
    [ fixnum/i               " x y -- x/y "                       [ 2 | 1 ] ]
    [ fixnum/f               " x y -- x/y "                       [ 2 | 1 ] ]
    [ fixnum-mod             " x y -- x%y "                       [ 2 | 1 ] ]
    [ fixnum/mod             " x y -- x/y x%y "                   [ 2 | 2 ] ]
    [ fixnum-bitand          " x y -- x&y "                       [ 2 | 1 ] ]
    [ fixnum-bitor           " x y -- x|y "                       [ 2 | 1 ] ]
    [ fixnum-bitxor          " x y -- x^y "                       [ 2 | 1 ] ]
    [ fixnum-bitnot          " x -- ~x "                          [ 1 | 1 ] ]
    [ fixnum-shift           " x n -- x<<n"                       [ 2 | 1 ] ]
    [ fixnum<                " x y -- ? "                         [ 2 | 1 ] ]
    [ fixnum<=               " x y -- ? "                         [ 2 | 1 ] ]
    [ fixnum>                " x y -- ? "                         [ 2 | 1 ] ]
    [ fixnum>=               " x y -- ? "                         [ 2 | 1 ] ]
    [ bignum=                " x y -- ? "                         [ 2 | 1 ] ]
    [ bignum+                " x y -- x+y "                       [ 2 | 1 ] ]
    [ bignum-                " x y -- x-y "                       [ 2 | 1 ] ]
    [ bignum*                " x y -- x*y "                       [ 2 | 1 ] ]
    [ bignum/i               " x y -- x/y "                       [ 2 | 1 ] ]
    [ bignum/f               " x y -- x/y "                       [ 2 | 1 ] ]
    [ bignum-mod             " x y -- x%y "                       [ 2 | 1 ] ]
    [ bignum/mod             " x y -- x/y x%y "                   [ 2 | 2 ] ]
    [ bignum-bitand          " x y -- x&y "                       [ 2 | 1 ] ]
    [ bignum-bitor           " x y -- x|y "                       [ 2 | 1 ] ]
    [ bignum-bitxor          " x y -- x^y "                       [ 2 | 1 ] ]
    [ bignum-bitnot          " x -- ~x "                          [ 1 | 1 ] ]
    [ bignum-shift           " x n -- x<<n"                       [ 2 | 1 ] ]
    [ bignum<                " x y -- ? "                         [ 2 | 1 ] ]
    [ bignum<=               " x y -- ? "                         [ 2 | 1 ] ]
    [ bignum>                " x y -- ? "                         [ 2 | 1 ] ]
    [ bignum>=               " x y -- ? "                         [ 2 | 1 ] ]
    [ float=                 " x y -- ? "                         [ 2 | 1 ] ]
    [ float+                 " x y -- x+y "                       [ 2 | 1 ] ]
    [ float-                 " x y -- x-y "                       [ 2 | 1 ] ]
    [ float*                 " x y -- x*y "                       [ 2 | 1 ] ]
    [ float/f                " x y -- x/y "                       [ 2 | 1 ] ]
    [ float<                 " x y -- ? "                         [ 2 | 1 ] ]
    [ float<=                " x y -- ? "                         [ 2 | 1 ] ]
    [ float>                 " x y -- ? "                         [ 2 | 1 ] ]
    [ float>=                " x y -- ? "                         [ 2 | 1 ] ]
    [ facos                  " x -- y "                           [ 1 | 1 ] ]
    [ fasin                  " x -- y "                           [ 1 | 1 ] ]
    [ fatan                  " x -- y "                           [ 1 | 1 ] ]
    [ fatan2                 " x y -- z "                         [ 2 | 1 ] ]
    [ fcos                   " x -- y "                           [ 1 | 1 ] ]
    [ fexp                   " x -- y "                           [ 1 | 1 ] ]
    [ fcosh                  " x -- y "                           [ 1 | 1 ] ]
    [ flog                   " x -- y "                           [ 1 | 1 ] ]
    [ fpow                   " x y -- z "                         [ 2 | 1 ] ]
    [ fsin                   " x -- y "                           [ 1 | 1 ] ]
    [ fsinh                  " x -- y "                           [ 1 | 1 ] ]
    [ fsqrt                  " x -- y "                           [ 1 | 1 ] ]
    [ <word>                 " prim param plist -- word "         [ 3 | 1 ] ]
    [ word-hashcode          " word -- n "                        [ 1 | 1 ] ]
    [ word-xt                " word -- xt "                       [ 1 | 1 ] ]
    [ set-word-xt            " xt word -- "                       [ 2 | 0 ] ]
    [ word-primitive         " word -- n "                        [ 1 | 1 ] ]
    [ set-word-primitive     " n word -- "                        [ 2 | 0 ] ]
    [ word-parameter         " word -- obj "                      [ 1 | 1 ] ]
    [ set-word-parameter     " obj word -- "                      [ 2 | 0 ] ]
    [ word-plist             " word -- alist"                     [ 1 | 1 ] ]
    [ set-word-plist         " alist word -- "                    [ 2 | 0 ] ]
    [ drop                   " x -- "                             [ 1 | 0 ] ]
    [ dup                    " x -- x x "                         [ 1 | 2 ] ]
    [ swap                   " x y -- y x "                       [ 2 | 2 ] ]
    [ over                   " x y -- x y x "                     [ 2 | 3 ] ]
    [ pick                   " x y z -- x y z x "                 [ 3 | 4 ] ]
    [ nip                    " x y -- y "                         [ 2 | 1 ] ]
    [ tuck                   " x y -- y x y "                     [ 2 | 3 ] ]
    [ rot                    " x y z -- y z x "                   [ 3 | 3 ] ]
    [ >r                     " x -- r:x "                         [ 1 | 0 ] ]
    [ r>                     " r:x -- x "                         [ 0 | 1 ] ]
    [ eq?                    " x y -- ? "                         [ 2 | 1 ] ]
    [ getenv                 " n -- obj "                         [ 1 | 1 ] ]
    [ setenv                 " obj n -- "                         [ 2 | 0 ] ]
    [ open-file              " path r w -- port "                 [ 3 | 1 ] ]
    [ stat                   " path -- [ dir? perm size mtime ] " [ 1 | 1 ] ]
    [ (directory)            " path -- list "                     [ 1 | 1 ] ]
    [ garbage-collection     " -- "                               [ 0 | 0 ] ]
    [ save-image             " path -- "                          [ 1 | 0 ] ]
    [ datastack              " -- ds "                            f ]
    [ callstack              " -- cs "                            f ]
    [ set-datastack          " ds -- "                            f ]
    [ set-callstack          " cs -- "                            f ]
    [ exit*                  " n -- "                             [ 1 | 0 ] ]
    [ client-socket          " host port -- in out "              [ 2 | 2 ] ]
    [ server-socket          " port -- server "                   [ 1 | 1 ] ]
    [ close-port             " port -- "                          [ 1 | 0 ] ]
    [ add-accept-io-task     " server callback -- "               [ 2 | 0 ] ]
    [ accept-fd              " server -- host port in out "       [ 1 | 4 ] ]
    [ can-read-line?         " port -- ? "                        [ 1 | 1 ] ]
    [ add-read-line-io-task  " port callback -- "                 [ 2 | 0 ] ]
    [ read-line-fd-8         " port -- sbuf "                     [ 1 | 1 ] ]
    [ can-read-count?        " n port -- ? "                      [ 2 | 1 ] ]
    [ add-read-count-io-task " n port callback -- "               [ 3 | 0 ] ]
    [ read-count-fd-8        " n port -- sbuf "                   [ 2 | 1 ] ]
    [ can-write?             " n port -- ? "                      [ 2 | 1 ] ]
    [ add-write-io-task      " port callback -- "                 [ 2 | 0 ] ]
    [ write-fd-8             " ch/str port -- "                   [ 2 | 0 ] ]
    [ add-copy-io-task       " from to callback -- "              [ 3 | 1 ] ]
    [ pending-io-error       " -- "                               [ 0 | 0 ] ]
    [ next-io-task           " -- callback "                      [ 0 | 1 ] ]
    [ room                   " -- free total free total "         [ 0 | 4 ] ]
    [ os-env                 " str -- str "                       [ 1 | 1 ] ]
    [ millis                 " -- n "                             [ 0 | 1 ] ]
    [ init-random            " -- "                               [ 0 | 0 ] ]
    [ (random-int)           " -- n "                             [ 0 | 1 ] ]
    [ type                   " obj -- n "                         [ 1 | 1 ] ]
    [ size                   " obj -- n "                         [ 1 | 1 ] ]
    [ call-profiling         " depth -- "                         [ 1 | 0 ] ]
    [ call-count             " word -- n "                        [ 1 | 1 ] ]
    [ set-call-count         " n word -- "                        [ 2 | 0 ] ]
    [ allot-profiling        " depth -- "                         [ 1 | 0 ] ]
    [ allot-count            " word -- n "                        [ 1 | 1 ] ]
    [ set-allot-count        " n word -- n "                      [ 2 | 1 ] ]
    [ cwd                    " -- dir "                           [ 0 | 1 ] ]
    [ cd                     " dir -- "                           [ 1 | 0 ] ]
    [ compiled-offset        " -- ptr "                           [ 0 | 1 ] ]
    [ set-compiled-offset    " ptr -- "                           [ 1 | 0 ] ]
    [ set-compiled-cell      " n ptr -- "                         [ 2 | 0 ] ]
    [ set-compiled-byte      " n ptr -- "                         [ 2 | 0 ] ]
    [ literal-top            " -- ptr "                           [ 0 | 1 ] ]
    [ set-literal-top        " ptr -- "                           [ 1 | 0 ] ]
    [ address                " obj -- ptr "                       [ 1 | 1 ] ]
    [ dlopen                 " path -- dll "                      [ 1 | 1 ] ]
    [ dlsym                  " name dll -- ptr "                  [ 2 | 1 ] ]
    [ dlsym-self             " name -- ptr "                      [ 1 | 1 ] ]
    [ dlclose                " dll -- "                           [ 1 | 0 ] ]
    [ <alien>                " ptr -- alien "                     [ 1 | 1 ] ]
    [ <local-alien>          " len -- alien "                     [ 1 | 1 ] ]
    [ alien-cell             " alien off -- n "                   [ 2 | 1 ] ]
    [ set-alien-cell         " n alien off -- "                   [ 3 | 0 ] ]
    [ alien-4                " alien off -- n "                   [ 2 | 1 ] ]
    [ set-alien-4            " n alien off -- "                   [ 3 | 0 ] ]
    [ alien-2                " alien off -- n "                   [ 2 | 1 ] ]
    [ set-alien-2            " n alien off -- "                   [ 3 | 0 ] ]
    [ alien-1                " alien off -- n "                   [ 2 | 1 ] ]
    [ set-alien-1            " n alien off -- "                   [ 3 | 0 ] ]
    [ heap-stats             " -- instances bytes "               [ 0 | 2 ] ]
    [ throw                  " error -- "                         [ 1 | 0 ] ]
] [
    uncons dupd uncons car ( word word stack-effect infer-effect )
    >r "stack-effect" set-word-property r>
    "infer-effect" set-word-property
] each
