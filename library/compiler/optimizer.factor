! :folding=indent:collapseFolds=1:

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

IN: compiler
USE: lists
USE: stack
USE: combinators
USE: namespaces
USE: kernel
USE: inference
USE: words
USE: prettyprint
USE: logic

! The optimizer transforms dataflow IR to dataflow IR. Currently
! it simply removes literals that are eventually dropped, and
! never arise as inputs to any other type of function. Such
! 'dead' literals arise when combinators are inlined and
! quotations are lifted to their call sites.

: scan-literal ( node -- )
    "scan-literal" [ 2drop ] apply-dataflow ;

: scan-literals ( dataflow -- list )
    [ [ scan-literal ] each ] make-list ;

: scan-branches ( branches -- )
    [ [ scan-literal ] each ] each ;

: mentions-literal? ( literal list -- )
    #! Does the given list of result objects refer to this
    #! literal?
    [ dup cons? [ car over = ] [ drop f ] ifte ] some? ;

: default-kill? ( literal node -- ? )
    [
        node-consume-d get mentions-literal? swap
        node-consume-r get mentions-literal? nip or not
    ] bind ;

: (can-kill?) ( literal node -- ? )
    #! Return false if the literal appears as input to this
    #! node, and this node is not a stack operation.
    dup [ node-op get ] bind dup "shuffle" word-property [
        3drop t
    ] [
        "can-kill" word-property dup [
            call
        ] [
            drop default-kill?
        ] ifte
    ] ifte ;

: can-kill? ( literal dataflow -- ? )
    [ dupd (can-kill?) ] all? nip ;

: kill-set ( dataflow -- list )
    #! Push a list of literals that may be killed in the IR.
    dup scan-literals [ over can-kill? ] subset nip ;

: can-kill-branches? ( literal node -- ? )
    [ node-param get ] bind [ dupd can-kill? ] all? nip ;

#push [ , ] "scan-literal" set-word-property
#ifte [ scan-branches ] "scan-literal" set-word-property
#ifte [ can-kill-branches? ] "can-kill" set-word-property
#generic [ scan-branches ] "scan-literal" set-word-property
#generic [ can-kill-branches? ] "can-kill" set-word-property
#2generic [ scan-branches ] "scan-literal" set-word-property
#2generic [ can-kill-branches? ] "can-kill" set-word-property
