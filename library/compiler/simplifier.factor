! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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
USE: kernel
USE: lists
USE: namespaces
USE: words
USE: inference
USE: strings
USE: strings
USE: prettyprint

! The linear IR being simplified is stored in this variable.
SYMBOL: simplifying

: simplifiers ( linear -- list )
    #! A list of quotations with stack effect
    #! ( linear -- linear ? ) that can simplify the first node
    #! in the linear IR.
    car car "simplifiers" word-property ;

: simplify-node ( linear list -- linear ? )
    dup [
        uncons >r call [
            r> drop t
        ] [
            r> simplify-node
        ] ifte
    ] when ;

: simplify-1 ( linear -- linear ? )
    #! Return a new linear IR.
    dup [
        dup simplifiers simplify-node
        [ uncons simplify-1 >r cons r> ] unless*
    ] [
        f
    ] ifte ;

: simplify ( linear -- linear )
    #! Keep simplifying until simplify-1 returns f.
    [
        dup simplifying set  simplify-1 [ simplify ] when
    ] with-scope ;

: label-called? ( label linear -- ? )
    [ unswons #label = [ drop f ] [ over = ] ifte ] some? nip ;

: next-physical? ( op linear -- ? )
    cdr dup [ car car = ] [ 2drop f ] ifte ;

: cancel ( linear op -- linear param ? )
    #! If the following op is as given, remove it, and return
    #! its param.
    over next-physical? [ cdr unswons cdr t ] [ f f ] ifte ;

#label [
    [
        dup car cdr simplifying get
        label-called? [ f ] [ cdr t ] ifte
    ]
] "simplifiers" set-word-property

\ >r [ [ \ r> cancel nip ] ] "simplifiers" set-word-property
\ r> [ [ \ >r cancel nip ] ] "simplifiers" set-word-property
\ dup [ [ \ drop cancel nip ] ] "simplifiers" set-word-property
\ swap [ [ \ swap cancel nip ] ] "simplifiers" set-word-property

: next-logical ( linear -- linear )
    dup car car "next-logical" word-property call ;

#label [
    cdr next-logical
] "next-logical" set-word-property

: find-label ( label -- rest )
    simplifying get [
        uncons pick = swap #label = and
    ] some? nip ;

#jump-label [
    car cdr find-label cdr
] "next-logical" set-word-property

#target-label [
    car cdr find-label cdr
] "next-logical" set-word-property

: next-logical? ( op linear -- ? )
    next-logical dup [ car car = ] [ 2drop f ] ifte ;

: reduce ( linear op new -- linear ? )
    >r over cdr next-logical? [
        unswons cdr r> swons swons t
    ] [
        r> drop f
    ] ifte ;

#call [
    [
        #return #jump reduce
    ]
] "simplifiers" set-word-property

#call-label [
    [
        #return #jump-label reduce
    ]
] "simplifiers" set-word-property

: double-jump ( linear op1 op2 -- linear ? )
    #! A jump to a jump is just a jump. If the next logical node
    #! is a jump of type op1, replace the jump at the car of the
    #! list with a just of type op2.
    swap pick next-logical? [
        over next-logical car cdr cons swap cdr cons t
    ] [
        drop f
    ] ifte ;

: useless-jump ( linear -- linear ? )
    #! A jump to a label immediately following is not needed.
    dup car cdr find-label over cdr eq? [ cdr t ] [ f ] ifte ;

: (dead-code) ( linear -- linear ? )
    #! Remove all nodes until the next #label.
    dup [
        dup car car #label = [
            f
        ] [
            cdr (dead-code) t or
        ] ifte
    ] [
        f
    ] ifte ;

: dead-code ( linear -- linear ? )
    uncons (dead-code) >r cons r> ;

#jump-label [
    [
        #return #return double-jump
    ] [
        #jump-label #jump-label double-jump
    ] [
        #jump #jump double-jump
    ] [
        useless-jump
    ] [
        dead-code
    ]
] "simplifiers" set-word-property

#target-label [
    [
        #jump-label #target-label double-jump
    ] [
        #jump #target double-jump
    ]
] "simplifiers" set-word-property

#jump [ [ dead-code ] ] "simplifiers" set-word-property
#return [ [ dead-code ] ] "simplifiers" set-word-property
#end-dispatch [ [ dead-code ] ] "simplifiers" set-word-property

\ drop [
    [
        #push-immediate cancel [
            #replace-immediate swons swons t
        ] when
    ] [
        #push-indirect cancel [
            #replace-indirect swons swons t
        ] when
    ]
] "simplifiers" set-word-property
