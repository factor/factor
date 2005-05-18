! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: alien errors generic hashtables kernel lists math
matrices memory namespaces parser presentation sequences stdio
streams strings unparser vectors words ;

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
        swap word-name "word" swons 
        swap "vocab" swons 
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

M: word prettyprint* ( indent word -- indent )
    dup parsing? [ \ POSTPONE: word. bl ] when word. ;

: indent ( indent -- )
    #! Print the given number of spaces.
    CHAR: \s fill write ;

: prettyprint-newline ( indent -- )
    "\n" write indent ;

: \? ( list -- ? )
    #! Is the head of the list a [ foo ] car?
    dup car dup cons? [
        dup car word? [
            cdr [ drop f ] [ cdr car \ car = ] ifte
        ] [
            2drop f
        ] ifte
    ] [
        2drop f
    ] ifte ;

: prettyprint-elements ( indent list -- indent )
    [
        dup \? [
            \ \ word. bl
            uncons >r car word. bl
            r> cdr prettyprint-elements
        ] [
            uncons >r prettyprint* bl
            r> prettyprint-elements
        ] ifte
    ] when* ;

: ?prettyprint-newline ( indent -- )
    one-line get [
        bl drop
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
        >r >r word. bl r> drop r> word.
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
    \ ALIEN: word. bl alien-address unparse write ;

: matrix-rows. ( indent list -- indent )
    uncons >r [ one-line on prettyprint* ] with-scope r>
    [ over ?prettyprint-newline matrix-rows. ] when* ;

M: matrix prettyprint* ( indent obj -- indent )
    \ M[ word. >r <prettyprint r>
    row-list matrix-rows.
    bl \ ]M word. prettyprint> ;

: prettyprint ( obj -- )
    [
        recursion-check off
        0 swap prettyprint* drop terpri
    ] with-scope ;

: vocab-link ( vocab -- link )
    "vocabularies'" swap append ;

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
: .n namestack  [.] flush ;
: .c catchstack [.] flush ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

global [ 4 tab-size set ] bind
