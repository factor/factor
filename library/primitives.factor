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

IN: alien
DEFER: alien

USE: alien
USE: compiler
USE: errors
USE: files
USE: generic
USE: io-internals
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: math-internals
USE: parser
USE: profiler
USE: random
USE: strings
USE: unparser
USE: vectors
USE: words

[
    [ execute                " word -- "                          f ]
    [ call                   " quot -- "                          [ [ general-list ] [ ] ] ]
    [ ifte                   " cond true false -- "               [ [ object general-list general-list ] [ ] ] ]
    [ cons                   " car cdr -- [ car | cdr ] "         [ [ object object ] [ cons ] ] ]
    [ car                    " [ car | cdr ] -- car "             [ [ cons ] [ object ] ] ]
    [ cdr                    " [ car | cdr ] -- cdr "             [ [ cons ] [ object ] ] ]
    [ <vector>               " capacity -- vector"                [ [ integer ] [ vector ] ] ]
    [ vector-length          " vector -- n "                      [ [ vector ] [ integer ] ] ]
    [ set-vector-length      " n vector -- "                      [ [ integer vector ] [ ] ] ]
    [ vector-nth             " n vector -- obj "                  [ [ integer vector ] [ object ] ] ]
    [ set-vector-nth         " obj n vector -- "                  [ [ object integer vector ] [ ] ] ]
    [ str-length             " str -- n "                         [ [ string ] [ integer ] ] ]
    [ str-nth                " n str -- ch "                      [ [ integer string ] [ integer ] ] ]
    [ str-compare            " str str -- -1/0/1 "                [ [ string string ] [ integer ] ] ]
    [ str=                   " str str -- ? "                     [ [ string string ] [ boolean ] ] ]
    [ str-hashcode           " str -- n "                         [ [ string ] [ integer ] ] ]
    [ index-of*              " n str/ch str -- n "                [ [ integer string text ] [ integer ] ] ]
    [ substring              " start end str -- str "             [ [ integer integer string ] [ string ] ] ]
    [ str-reverse            " str -- str "                       [ [ string ] [ string ] ] ]
    [ <sbuf>                 " capacity -- sbuf "                 [ [ integer ] [ sbuf ] ] ]
    [ sbuf-length            " sbuf -- n "                        [ [ sbuf ] [ integer ] ] ]
    [ set-sbuf-length        " n sbuf -- "                        [ [ integer sbuf ] [ ] ] ]
    [ sbuf-nth               " n sbuf -- ch "                     [ [ integer sbuf ] [ integer ] ] ]
    [ set-sbuf-nth           " ch n sbuf -- "                     [ [ integer integer sbuf ] [ ] ] ]
    [ sbuf-append            " ch/str sbuf -- "                   [ [ text sbuf ] [ ] ] ]
    [ sbuf>str               " sbuf -- str "                      [ [ sbuf ] [ string ] ] ]
    [ sbuf-reverse           " sbuf -- "                          [ [ sbuf ] [ ] ] ]
    [ sbuf-clone             " sbuf -- sbuf "                     [ [ sbuf ] [ sbuf ] ] ]
    [ sbuf=                  " sbuf sbuf -- ? "                   [ [ sbuf sbuf ] [ boolean ] ] ]
    [ sbuf-hashcode          " sbuf -- n "                        [ [ sbuf ] [ integer ] ] ]
    [ arithmetic-type        " n n -- type "                      [ [ number number ] [ number number fixnum ] ] ]
    [ >fixnum                " n -- fixnum "                      [ [ number ] [ fixnum ] ] ]
    [ >bignum                " n -- bignum "                      [ [ number ] [ bignum ] ] ]
    [ >float                 " n -- float "                       [ [ number ] [ float ] ] ]
    [ numerator              " a/b -- a "                         [ [ rational ] [ integer ] ] ]
    [ denominator            " a/b -- b "                         [ [ rational ] [ integer ] ] ]
    [ fraction>              " a b -- a/b "                       [ [ integer integer ] [ rational ] ] ]
    [ str>float              " str -- float "                     [ [ string ] [ float ] ] ]
    [ (unparse-float)        " float -- str "                     [ [ float ] [ string ] ] ]
    [ float>bits             " float -- n "                       [ [ float ] [ integer ] ] ]
    [ real                   " #{ re im } -- re "                 [ [ number ] [ real ] ] ]
    [ imaginary              " #{ re im } -- im "                 [ [ number ] [ real ] ] ]
    [ rect>                  " re im -- #{ re im } "              [ [ real real ] [ number ] ] ]
    [ fixnum=                " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ fixnum+                " x y -- x+y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum-                " x y -- x-y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum*                " x y -- x*y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum/i               " x y -- x/y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum/f               " x y -- x/y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum-mod             " x y -- x%y "                       [ [ fixnum fixnum ] [ integer ] ] ]
    [ fixnum/mod             " x y -- x/y x%y "                   [ [ fixnum fixnum ] [ integer integer ] ] ]
    [ fixnum-bitand          " x y -- x&y "                       [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ fixnum-bitor           " x y -- x|y "                       [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ fixnum-bitxor          " x y -- x^y "                       [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ fixnum-bitnot          " x -- ~x "                          [ [ fixnum ] [ fixnum ] ] ]
    [ fixnum-shift           " x n -- x<<n"                       [ [ fixnum fixnum ] [ fixnum ] ] ]
    [ fixnum<                " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ fixnum<=               " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ fixnum>                " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ fixnum>=               " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ bignum=                " x y -- ? "                         [ [ fixnum fixnum ] [ boolean ] ] ]
    [ bignum+                " x y -- x+y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum-                " x y -- x-y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum*                " x y -- x*y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum/i               " x y -- x/y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum/f               " x y -- x/y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum-mod             " x y -- x%y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum/mod             " x y -- x/y x%y "                   [ [ bignum bignum ] [ bignum bignum ] ] ]
    [ bignum-bitand          " x y -- x&y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum-bitor           " x y -- x|y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum-bitxor          " x y -- x^y "                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum-bitnot          " x -- ~x "                          [ [ bignum ] [ bignum ] ] ]
    [ bignum-shift           " x n -- x<<n"                       [ [ bignum bignum ] [ bignum ] ] ]
    [ bignum<                " x y -- ? "                         [ [ bignum bignum ] [ boolean ] ] ]
    [ bignum<=               " x y -- ? "                         [ [ bignum bignum ] [ boolean ] ] ]
    [ bignum>                " x y -- ? "                         [ [ bignum bignum ] [ boolean ] ] ]
    [ bignum>=               " x y -- ? "                         [ [ bignum bignum ] [ boolean ] ] ]
    [ float=                 " x y -- ? "                         [ [ bignum bignum ] [ boolean ] ] ]
    [ float+                 " x y -- x+y "                       [ [ float float ] [ float ] ] ]
    [ float-                 " x y -- x-y "                       [ [ float float ] [ float ] ] ]
    [ float*                 " x y -- x*y "                       [ [ float float ] [ float ] ] ]
    [ float/f                " x y -- x/y "                       [ [ float float ] [ float ] ] ]
    [ float<                 " x y -- ? "                         [ [ float float ] [ boolean ] ] ]
    [ float<=                " x y -- ? "                         [ [ float float ] [ boolean ] ] ]
    [ float>                 " x y -- ? "                         [ [ float float ] [ boolean ] ] ]
    [ float>=                " x y -- ? "                         [ [ float float ] [ boolean ] ] ]
    [ facos                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ fasin                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ fatan                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ fatan2                 " x y -- z "                         [ [ real real ] [ float ] ] ]
    [ fcos                   " x -- y "                           [ [ real ] [ float ] ] ]
    [ fexp                   " x -- y "                           [ [ real ] [ float ] ] ]
    [ fcosh                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ flog                   " x -- y "                           [ [ real ] [ float ] ] ]
    [ fpow                   " x y -- z "                         [ [ real real ] [ float ] ] ]
    [ fsin                   " x -- y "                           [ [ real ] [ float ] ] ]
    [ fsinh                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ fsqrt                  " x -- y "                           [ [ real ] [ float ] ] ]
    [ <word>                 " prim param plist -- word "         [ [ integer object general-list ] [ word ] ] ]
    [ word-hashcode          " word -- n "                        [ [ word ] [ integer ] ] ]
    [ word-xt                " word -- xt "                       [ [ word ] [ integer ] ] ]
    [ set-word-xt            " xt word -- "                       [ [ integer word ] [ ] ] ]
    [ word-primitive         " word -- n "                        [ [ word ] [ integer ] ] ]
    [ set-word-primitive     " n word -- "                        [ [ integer word ] [ ] ] ]
    [ word-parameter         " word -- obj "                      [ [ word ] [ object ] ] ]
    [ set-word-parameter     " obj word -- "                      [ [ object word ] [ ] ] ]
    [ word-plist             " word -- alist"                     [ [ word ] [ general-list ] ] ]
    [ set-word-plist         " alist word -- "                    [ [ general-list word ] [ ] ] ]
    [ drop                   " x -- "                             [ [ object ] [ ] ] ]
    [ dup                    " x -- x x "                         [ [ object ] [ object object ] ] ]
    [ swap                   " x y -- y x "                       [ [ object object ] [ object object ] ] ]
    [ over                   " x y -- x y x "                     [ [ object object ] [ object object object ] ] ]
    [ pick                   " x y z -- x y z x "                 [ [ object object object ] [ object object object object ] ] ]
    [ >r                     " x -- r:x "                         [ [ object ] [ ] ] ]
    [ r>                     " r:x -- x "                         [ [ ] [ object ] ] ]
    [ eq?                    " x y -- ? "                         [ [ object object ] [ boolean ] ] ]
    [ getenv                 " n -- obj "                         [ [ fixnum ] [ object ] ] ]
    [ setenv                 " obj n -- "                         [ [ object fixnum ] [ ] ] ]
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
    [ heap-stats             " -- instances bytes "               [ [ ] [ general-list ] ] ]
    [ throw                  " error -- "                         [ [ object ] [ ] ] ]
    [ string>memory          " str address -- "                   [ [ string integer ] [ ] ] ]
    [ memory>string          " address length -- str "            [ [ integer integer ] [ string ] ] ]
    [ local-alien?           " alien -- ? "                       [ [ alien ] [ object ] ] ]
    [ alien-address          " alien -- address "                 [ [ alien ] [ integer ] ] ]
] [
    uncons dupd uncons car ( word word stack-effect infer-effect )
    >r "stack-effect" set-word-property r>
    "infer-effect" set-word-property
] each
