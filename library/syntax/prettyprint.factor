! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: alien errors generic hashtables io kernel lists math
memory namespaces parser presentation sequences strings
styles unparser vectors words ;

SYMBOL: prettyprint-limit
SYMBOL: one-line
SYMBOL: tab-size
SYMBOL: recursion-check

GENERIC: prettyprint* ( indent obj -- indent )

: object. ( str obj -- )
    presented swons unit format ;

: unparse. ( obj -- )
    [ unparse ] keep object. ;

M: object prettyprint* ( indent obj -- indent )
    unparse. ;

M: word prettyprint* ( indent word -- indent )
    dup parsing? [ \ POSTPONE: unparse. bl ] when unparse. ;

: indent ( indent -- )
    #! Print the given number of spaces.
    CHAR: \s fill write ;

: prettyprint-newline ( indent -- )
    "\n" write indent ;

: ?prettyprint-newline ( indent -- )
    one-line get [ bl drop ] [ prettyprint-newline ] ifte ;

: <prettyprint ( indent -- indent )
    tab-size get + dup ?prettyprint-newline ;

: prettyprint> ( indent -- indent )
    tab-size get - one-line get
    [ dup prettyprint-newline ] unless ;

: prettyprint-limit? ( indent -- ? )
    prettyprint-limit get dup [ >= ] [ nip ] ifte ;

: check-recursion ( indent obj quot -- indent )
    #! We detect circular structure.
    pick prettyprint-limit? [
        2drop "#" write
    ] [
        over recursion-check get memq? [
            2drop "&" write
        ] [
            over recursion-check [ cons ] change
            call
            recursion-check [ cdr ] change
        ] ifte
    ] ifte ; inline

: prettyprint-elements ( indent list -- indent )
    [ prettyprint* bl ] each ;

: prettyprint-sequence ( indent start list end -- indent )
    #! Prettyprint a list, with start/end delimiters; eg, [ ],
    #! or { }, or << >>. The body of the list is indented,
    #! unless the list is empty.
    over [
        >r >r unparse. <prettyprint
        r> prettyprint-elements
        prettyprint> r> unparse.
    ] [
        >r >r unparse. bl r> drop r> unparse.
    ] ifte ;

M: cons prettyprint* ( indent list -- indent )
   [
       dup list? [
           \ [ swap \ ]
       ] [
           \ [[ swap uncons 2list \ ]]
       ] ifte prettyprint-sequence
   ] check-recursion ;

M: vector prettyprint* ( indent vector -- indent )
    [
        \ { swap \ } prettyprint-sequence
    ] check-recursion ;

M: hashtable prettyprint* ( indent hashtable -- indent )
    [
        \ {{ swap hash>alist \ }} prettyprint-sequence
    ] check-recursion ;

M: tuple prettyprint* ( indent tuple -- indent )
    [
        \ << swap <mirror> \ >> prettyprint-sequence
    ] check-recursion ;

M: alien prettyprint* ( alien -- )
    \ ALIEN: unparse. bl alien-address unparse write ;

M: wrapper prettyprint* ( wrapper -- )
    dup wrapped word? [
        \ \ unparse. bl wrapped unparse.
    ] [
        \ W[ unparse. bl wrapped prettyprint* \ ]W unparse.
    ] ifte ;

: prettyprint ( obj -- )
    [
        recursion-check off
        0 swap prettyprint* drop terpri
    ] with-scope ;

: . ( obj -- )
    [
        one-line on
        16 prettyprint-limit set
        prettyprint
    ] with-scope ;

: [.] ( sequence -- )
    #! Unparse each element on its own line.
    [ . ] each ;

: .s datastack  reverse [.] flush ;
: .r callstack  reverse [.] flush ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

global [ 4 tab-size set ] bind
