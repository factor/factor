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
USE: inference
USE: errors
USE: generic
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stdio
USE: strings
USE: unparser
USE: vectors
USE: words

: labels ( linear -- list )
    #! Make a list of all labels defined in the linear IR.
    [ [ unswons #label = [ , ] [ drop ] ifte ] each ] make-list ;

: label-called? ( label linear -- ? )
    [ unswons #label = [ drop f ] [ over = ] ifte ] some? nip ;

: purge-label ( label linear -- )
    >r dup cdr r> label-called? [ , ] [ drop ] ifte ;

: purge-labels ( linear -- linear )
    #! Remove all unused labels.
    [
        dup [
            dup car #label = [ over purge-label ] [ , ] ifte
        ] each drop
    ] make-list ;

: singleton ( word op default -- )
    >r word-property dup [
        r> drop call
    ] [
        drop r> call
    ] ifte ;

: simplify-node ( node rest -- rest ? )
    over car "simplify" [ swap , f ] singleton ;

: find-label ( label linear -- rest )
    [ cdr over = ] some? cdr nip ;

: (simplify) ( list -- ? )
    dup [ uncons simplify-node drop (simplify) ] [ drop ] ifte ;

: simplify ( linear -- linear )
    ( purge-labels ) [ (simplify) ] make-list ;

: follow ( linear -- linear )
    dup car car "follow" [ ] singleton ;

#label [
    cdr follow
] "follow" set-word-property

#jump-label [
    uncons >r cdr r> find-label follow
] "follow" set-word-property

: follows? ( op linear -- ? )
    follow dup [ car car = ] [ 2drop f ] ifte ;

GENERIC: simplify-call ( node rest -- rest ? )
M: cons simplify-call ( node rest -- rest ? )
    swap , f ;

PREDICATE: cons return-follows #return swap follows? ;
M: return-follows simplify-call ( node rest -- rest ? )
    >r
    unswons [
        [ #call | #jump ]
        [ #call-label | #jump-label ]
    ] assoc swons , r> t ;

#call [ simplify-call ] "simplify" set-word-property
#call-label [ simplify-call ] "simplify" set-word-property

GENERIC: simplify-drop ( node rest -- rest ? )
M: cons simplify-drop ( node rest -- rest ? )
    swap , f ;

PREDICATE: cons push-next ( list -- ? )
    dup [
        car car [ #push-immediate #push-indirect ] contains?
    ] when ;

M: push-next simplify-drop ( node rest -- rest ? )
    nip uncons >r unswons [
        [ #push-immediate | #replace-immediate ]
        [ #push-indirect | #replace-indirect ]
    ] assoc swons , r> t ;

#drop [ simplify-drop ] "simplify" set-word-property
