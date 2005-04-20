! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: alien errors generic hashtables kernel lists math memory
namespaces parser presentation sequences stdio streams strings
unparser vectors words ;

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

: word-actions ( -- list )
    [
        [[ "See"        "see"          ]]
        [[ "Push"       ""             ]]
        [[ "Execute"    "execute"      ]]
        [[ "jEdit"      "jedit"        ]]
        [[ "Usages"     "usages ."     ]]
        [[ "Implements" "implements ." ]]
    ] ;

: browser-attrs ( word -- style )
    #! Return the style values for the HTML word browser
    dup word-vocabulary [ 
        swap word-name "browser-link-word" swons 
        swap "browser-link-vocab" swons 
        2list
    ] [
        drop [ ]  
    ] ifte* ;

: word-attrs ( word -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    dup word-vocabulary [
         dup word-link word-actions <actions> "actions" swons unit
         swap browser-attrs append
    ] [
        drop [ ]
    ] ifte ;

: word. ( word -- ) dup word-name swap word-attrs write-attr ;
: word-bl word. " " write ;

M: word prettyprint* ( indent word -- indent )
    dup parsing? [ \ POSTPONE: word-bl ] when word. ;

: indent ( indent -- )
    #! Print the given number of spaces.
    CHAR: \s fill write ;

: prettyprint-newline ( indent -- )
    "\n" write indent ;

: prettyprint-elements ( indent list -- indent )
    [ prettyprint* " " write ] each ;

: ?prettyprint-newline ( indent -- )
    one-line get [
        " " write drop
    ] [
        prettyprint-newline
    ] ifte ;

: <prettyprint ( indent -- indent )
    tab-size get + dup ?prettyprint-newline ;

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
        >r >r word. <prettyprint
        r> prettyprint-elements
        prettyprint> r> word.
    ] [
        >r >r word. " " write r> drop r> word.
    ] ifte ;

M: list prettyprint* ( indent list -- indent )
   [
       \ [ swap \ ] prettyprint-sequence
   ] check-recursion ;

M: cons prettyprint* ( indent cons -- indent )
    #! Here we turn the cons into a list of two elements.
    [
        \ [[ swap uncons 2list \ ]] prettyprint-sequence
    ] check-recursion ;

M: vector prettyprint* ( indent vector -- indent )
    [
        \ { swap >list \ } prettyprint-sequence
    ] check-recursion ;

M: hashtable prettyprint* ( indent hashtable -- indent )
    [
        \ {{ swap hash>alist \ }} prettyprint-sequence
    ] check-recursion ;

M: tuple prettyprint* ( indent tuple -- indent )
    [
        \ << swap tuple>list \ >> prettyprint-sequence
    ] check-recursion ;

M: alien prettyprint* ( alien -- str )
    \ ALIEN: word-bl alien-address unparse write ;

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
    >list reverse [ . ] each ;

: .s datastack  {.} ;
: .r callstack  {.} ;
: .n namestack  [.] ;
: .c catchstack [.] ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

global [ 4 tab-size set ] bind
