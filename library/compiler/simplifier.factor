! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: inference kernel lists math namespaces prettyprint
strings words ;

! The linear IR being simplified is stored in this variable.
SYMBOL: simplifying

: simplifiers ( linear -- list )
    #! A list of quotations with stack effect
    #! ( linear -- linear ? ) that can simplify the first node
    #! in the linear IR.
    car car "simplifiers" word-prop ;

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
    [ uncons pick = swap #label = not and ] some? nip ;

#label [
    [
        dup car cdr simplifying get label-called?
        [ f ] [ cdr t ] ifte
    ]
] "simplifiers" set-word-prop

: next-physical? ( op linear -- ? )
    cdr dup [ car car = ] [ 2drop f ] ifte ;

: cancel ( linear op -- linear param ? )
    #! If the following op is as given, remove it, and return
    #! its param.
    over next-physical? [ cdr unswons cdr t ] [ f f ] ifte ;

\ >r [ [ \ r> cancel nip ] ] "simplifiers" set-word-prop
\ r> [ [ \ >r cancel nip ] ] "simplifiers" set-word-prop
\ dup [ [ \ drop cancel nip ] ] "simplifiers" set-word-prop
\ swap [ [ \ swap cancel nip ] ] "simplifiers" set-word-prop

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
] "simplifiers" set-word-prop

: find-label ( label -- rest )
    simplifying get [
        uncons pick = swap #label = and
    ] some? nip ;

: next-logical ( linear -- linear )
    dup car car "next-logical" word-prop call ;

#label [
    cdr next-logical
] "next-logical" set-word-prop

#jump-label [
    car cdr find-label cdr
] "next-logical" set-word-prop

#target-label [
    car cdr find-label cdr
] "next-logical" set-word-prop

: next-logical? ( op linear -- ? )
    next-logical dup [ car car = ] [ 2drop f ] ifte ;

: reduce ( linear op new -- linear ? )
    >r over cdr next-logical? [
        unswons cdr r> swons swons t
    ] [
        r> drop f
    ] ifte ;

#call [
    [ #return #jump reduce ]
] "simplifiers" set-word-prop

#call-label [
    [ #return #jump-label reduce ]
] "simplifiers" set-word-prop

: double-jump ( linear op1 op2 -- linear ? )
    #! A jump to a jump is just a jump. If the next logical node
    #! is a jump of type op1, replace the jump at the car of the
    #! list with a jump of type op2.
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
    [ #return #return double-jump ]
    [ #jump-label #jump-label double-jump ]
    [ #jump #jump double-jump ]
    [ useless-jump ]
    [ dead-code ]
] "simplifiers" set-word-prop

#target-label [
    [ #jump-label #target-label double-jump ]
    [ #jump #target double-jump ]
] "simplifiers" set-word-prop

#jump [ [ dead-code ] ] "simplifiers" set-word-prop
#return [ [ dead-code ] ] "simplifiers" set-word-prop
#end-dispatch [ [ dead-code ] ] "simplifiers" set-word-prop
