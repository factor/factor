! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint

! This using kernel-internals is pretty bad. Remove the
! kernel-internals usage as soon as the tuple class is moved
! to the generic vocabulary.
USING: errors generic kernel kernel-internals lists math
namespaces stdio strings presentation unparser vectors words
hashtables parser ;

SYMBOL: prettyprint-limit
SYMBOL: one-line
SYMBOL: tab-size
SYMBOL: recursion-check

GENERIC: prettyprint* ( indent obj -- indent )

M: object prettyprint* ( indent obj -- indent )
    unparse write ;

: word-link ( word -- link )
    [
        dup word-name unparse ,
        " [ " ,
        word-vocabulary unparse ,
        " ] search" ,
    ] make-string ;

: word-actions ( search -- list )
    [
        [[ "See"     "see"     ]]
        [[ "Push"    ""        ]]
        [[ "Execute" "execute" ]]
        [[ "jEdit"   "jedit"   ]]
        [[ "Usages"  "usages." ]]
    ] ;

: word-attrs ( word -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    dup word-vocabulary [
        word-link word-actions <actions> "actions" swons unit
    ] [
        drop [ ]
    ] ifte ;

: prettyprint-word ( word -- )
    dup word-name
    swap dup word-attrs swap word-style append
    write-attr ;

M: word prettyprint* ( indent word -- indent )
    dup parsing? [
        \ POSTPONE: prettyprint-word " " write
    ] when
    prettyprint-word ;

: indent ( indent -- )
    #! Print the given number of spaces.
    " " fill write ;

: prettyprint-newline ( indent -- )
    "\n" write indent ;

: prettyprint-elements ( indent list -- indent )
    [ prettyprint* " " write ] each ;

: <prettyprint ( indent -- indent )
    tab-size get + one-line get [
        " " write
    ] [
        dup prettyprint-newline
    ] ifte ;

: prettyprint> ( indent -- indent )
    tab-size get - one-line get
    [ dup prettyprint-newline ] unless ;

: prettyprint-limit? ( indent -- ? )
    prettyprint-limit get dup [ >= ] [ nip ] ifte ;

: check-recursion ( indent obj quot -- ? indent )
    #! We detect circular structure.
    pick prettyprint-limit? >r
    over recursion-check get memq? r> or [
        2drop "..." write
    ] [
        over recursion-check [ cons ] change
        call
        recursion-check [ cdr ] change
    ] ifte ;

: prettyprint-sequence ( indent start list end -- indent )
    #! Prettyprint a list, with start/end delimiters; eg, [ ],
    #! or { }, or << >>. The body of the list is indented,
    #! unless the list is empty.
    over [
        >r
        >r prettyprint-word <prettyprint
        r> prettyprint-elements
        prettyprint> r> prettyprint-word
    ] [
        >r >r prettyprint-word " " write
        r> drop
        r> prettyprint-word
    ] ifte ;

M: list prettyprint* ( indent list -- indent )
    [
        [
            \ [ swap \ ] prettyprint-sequence
        ] check-recursion
    ] [
        f unparse write
    ] ifte* ;

M: cons prettyprint* ( indent cons -- indent )
    #! Here we turn the cons into a list of two elements.
    [
        \ [[ swap uncons 2list \ ]] prettyprint-sequence
    ] check-recursion ;

M: vector prettyprint* ( indent vector -- indent )
    [
        \ { swap vector>list \ } prettyprint-sequence
    ] check-recursion ;

M: hashtable prettyprint* ( indent hashtable -- indent )
    [
        \ {{ swap hash>alist \ }} prettyprint-sequence
    ] check-recursion ;

M: tuple prettyprint* ( indent tuple -- indent )
    [
        \ << swap tuple>list \ >> prettyprint-sequence
    ] check-recursion ;

: prettyprint ( obj -- )
    [
        recursion-check off
        0 swap prettyprint* drop terpri
    ] with-scope ;

: vocab-link ( vocab -- link )
    "vocabularies'" swap cat2 ;

: . ( obj -- )
    [
        one-line on
        16 prettyprint-limit set
        prettyprint
    ] with-scope ;

: [.] ( list -- )
    #! Unparse each element on its own line.
    [ . ] each ;

: {.} ( vector -- )
    #! Unparse each element on its own line.
    vector>list reverse [ . ] each ;

: .s datastack  {.} ;
: .r callstack  {.} ;
: .n namestack  [.] ;
: .c catchstack [.] ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

global [ 4 tab-size set ] bind
