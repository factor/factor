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
DEFER: dll

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
    [ <vector>               " capacity -- vector"                [ [ integer ] [ vector ] ] ]
    [ vector-nth             " n vector -- obj "                  [ [ integer vector ] [ object ] ] ]
    [ set-vector-nth         " obj n vector -- "                  [ [ object integer vector ] [ ] ] ]
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
    [ (fraction>)            " a b -- a/b "                       [ [ integer integer ] [ rational ] ] ]
    [ str>float              " str -- float "                     [ [ string ] [ float ] ] ]
    [ (unparse-float)        " float -- str "                     [ [ float ] [ string ] ] ]
    [ (rect>)                " re im -- #{ re im } "              [ [ real real ] [ number ] ] ]
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
    [ <word>                 " -- word "                          [ [ ] [ word ] ] ]
    [ update-xt              " word -- "                          [ [ word ] [ ] ] ]
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
    [ open-file              " path r w -- port "                 [ [ string object object ] [ port ] ] ]
    [ stat                   " path -- [ dir? perm size mtime ] " [ [ string ] [ cons ] ] ]
    [ (directory)            " path -- list "                     [ [ string ] [ general-list ] ] ]
    [ garbage-collection     " -- "                               [ [ ] [ ] ] ]
    [ save-image             " path -- "                          [ [ string ] [ ] ] ]
    [ datastack              " -- ds "                            f ]
    [ callstack              " -- cs "                            f ]
    [ set-datastack          " ds -- "                            f ]
    [ set-callstack          " cs -- "                            f ]
    [ exit*                  " n -- "                             [ [ integer ] [ ] ] ]
    [ client-socket          " host port -- in out "              [ [ string integer ] [ port port ] ] ]
    [ server-socket          " port -- server "                   [ [ integer ] [ port ] ] ]
    [ close-port             " port -- "                          [ [ port ] ] ]
    [ add-accept-io-task     " server callback -- "               [ [ port general-list ] [ ] ] ]
    [ accept-fd              " server -- host port in out "       [ [ port ] [ string integer port port ] ] ]
    [ can-read-line?         " port -- ? "                        [ [ port ] [ boolean ] ] ]
    [ add-read-line-io-task  " port callback -- "                 [ [ port general-list ] [ ] ] ]
    [ read-line-fd-8         " port -- sbuf "                     [ [ port ] [ sbuf ] ] ]
    [ can-read-count?        " n port -- ? "                      [ [ integer port ] [ boolean ] ] ]
    [ add-read-count-io-task " n port callback -- "               [ [ integer port general-list ] [ ] ] ]
    [ read-count-fd-8        " n port -- sbuf "                   [ [ integer port ] [ sbuf ] ] ]
    [ can-write?             " n port -- ? "                      [ [ integer port ] [ boolean ] ] ]
    [ add-write-io-task      " port callback -- "                 [ [ port general-list ] [ ] ] ]
    [ write-fd-8             " ch/str port -- "                   [ [ text port ] [ ] ] ]
    [ add-copy-io-task       " from to callback -- "              [ [ port port general-list ] [ ] ] ]
    [ pending-io-error       " -- "                               [ [ ] [ ] ] ]
    [ next-io-task           " -- callback "                      [ [ ] [ general-list ] ] ]
    [ room                   " -- free total free total "         [ [ ] [ integer integer integer integer ] ] ]
    [ os-env                 " str -- str "                       [ [ string ] [ object ] ] ]
    [ millis                 " -- n "                             [ [ ] [ integer ] ] ]
    [ init-random            " -- "                               [ [ ] [ ] ] ]
    [ (random-int)           " -- n "                             [ [ ] [ integer ] ] ]
    [ type                   " obj -- n "                         [ [ object ] [ fixnum ] ] ]
    [ call-profiling         " depth -- "                         [ [ integer ] [ ] ] ]
    [ allot-profiling        " depth -- "                         [ [ integer ] [ ] ] ]
    [ cwd                    " -- dir "                           [ [ ] [ string ] ] ]
    [ cd                     " dir -- "                           [ [ string ] [ ] ] ]
    [ compiled-offset        " -- ptr "                           [ [ ] [ integer ] ] ]
    [ set-compiled-offset    " ptr -- "                           [ [ integer ] [ ] ] ]
    [ literal-top            " -- ptr "                           [ [ ] [ integer ] ] ]
    [ set-literal-top        " ptr -- "                           [ [ integer ] [ ] ] ]
    [ address                " obj -- ptr "                       [ [ object ] [ integer ] ] ]
    [ dlopen                 " path -- dll "                      [ [ string ] [ dll ] ] ]
    [ dlsym                  " name dll -- ptr "                  [ [ string dll ] [ integer ] ] ]
    [ dlsym-self             " name -- ptr "                      [ [ string ] [ integer ] ] ]
    [ dlclose                " dll -- "                           [ [ dll ] [ ] ] ]
    [ <alien>                " ptr -- alien "                     [ [ integer ] [ alien ] ] ]
    [ <local-alien>          " len -- alien "                     [ [ integer ] [ alien ] ] ]
    [ alien-cell             " alien off -- n "                   [ [ alien integer ] [ integer ] ] ]
    [ set-alien-cell         " n alien off -- "                   [ [ integer alien integer ] [ ] ] ]
    [ alien-4                " alien off -- n "                   [ [ alien integer ] [ integer ] ] ]
    [ set-alien-4            " n alien off -- "                   [ [ integer alien integer ] [ ] ] ]
    [ alien-2                " alien off -- n "                   [ [ alien integer ] [ fixnum ] ] ]
    [ set-alien-2            " n alien off -- "                   [ [ integer alien integer ] [ ] ] ]
    [ alien-1                " alien off -- n "                   [ [ alien integer ] [ fixnum ] ] ]
    [ set-alien-1            " n alien off -- "                   [ [ integer alien integer ] [ ] ] ]
    [ heap-stats             " -- instances bytes "               [ [ ] [ general-list ] ] ]
    [ throw                  " error -- "                         [ [ object ] [ ] ] ]
    [ string>memory          " str address -- "                   [ [ string integer ] [ ] ] ]
    [ memory>string          " address length -- str "            [ [ integer integer ] [ string ] ] ]
    [ local-alien?           " alien -- ? "                       [ [ alien ] [ object ] ] ]
    [ alien-address          " alien -- address "                 [ [ alien ] [ integer ] ] ]
    [ >cons                  " cons -- cons "                     [ [ cons ] [ cons ] ] ]
    [ >vector                " vector -- vector "                 [ [ vector ] [ vector ] ] ]
    [ >string                " string -- string "                 [ [ string ] [ string ] ] ]
    [ >word                  " word -- word "                     [ [ word ] [ word ] ] ]
    [ slot                   " obj n -- obj "                     [ [ object fixnum ] [ object ] ] ]
    [ set-slot               " obj obj n -- "                     [ [ object object fixnum ] [ ] ] ]
    [ integer-slot           " obj n -- n "                       [ [ object fixnum ] [ integer ] ] ]
    [ set-integer-slot       " n obj n -- "                       [ [ integer object fixnum ] [ ] ] ]
    [ grow-array             " n array -- array "                 [ [ integer array ] [ integer ] ] ]
] [
    uncons dupd uncons car ( word word stack-effect infer-effect )
    >r "stack-effect" set-word-property r>
    "infer-effect" set-word-property
] each
