! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: errors generic kernel lists math namespaces stdio strings
presentation unparser vectors words hashtables ;

SYMBOL: prettyprint-limit

GENERIC: prettyprint* ( indent obj -- indent )

M: object prettyprint* ( indent obj -- indent )
    unparse write ;

: tab-size
    #! Change this to suit your tastes.
    4 ;

: indent ( indent -- )
    #! Print the given number of spaces.
    " " fill write ;

: prettyprint-newline ( indent -- )
    "\n" write indent ;

: prettyprint-element ( indent obj -- indent )
    over prettyprint-limit get >= [
        unparse write
    ] [
        prettyprint*
    ] ifte " " write ;

: <prettyprint ( indent -- indent )
    tab-size +
    "prettyprint-single-line" get [
        " " write
    ] [
        dup prettyprint-newline
    ] ifte ;

: prettyprint> ( indent -- indent )
    tab-size -
    "prettyprint-single-line" get [
        dup prettyprint-newline
    ] unless ;

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

M: word prettyprint* ( indent word -- indent )
    dup word-name
    swap dup word-attrs swap word-style append
    write-attr ;

: prettyprint-[ ( indent -- indent )
    \ [ prettyprint* <prettyprint ;

: prettyprint-] ( indent -- indent )
    prettyprint> \ ] prettyprint* ;

: prettyprint-list ( indent list -- indent )
    #! Pretty-print a list, without [ and ].
    [ prettyprint-element ] each ;

M: list prettyprint* ( indent list -- indent )
    [
        swap prettyprint-[ swap prettyprint-list prettyprint-]
    ] [
        f unparse write
    ] ifte* ;

M: cons prettyprint* ( indent cons -- indent )
    \ [[ prettyprint* " " write
            uncons >r prettyprint-element r> prettyprint-element
    \ ]] prettyprint* ;

: prettyprint-{ ( indent -- indent )
    \ { prettyprint* <prettyprint ;

: prettyprint-} ( indent -- indent )
    prettyprint> \ } prettyprint* ;

: prettyprint-vector ( indent list -- indent )
    #! Pretty-print a vector, without { and }.
    [ prettyprint-element ] vector-each ;

M: vector prettyprint* ( indent vector -- indent )
    dup vector-length 0 = [
        drop
        \ { prettyprint*
        " " write
        \ } prettyprint*
    ] [
        swap prettyprint-{ swap prettyprint-vector prettyprint-}
    ] ifte ;

: prettyprint-{{ ( indent -- indent )
    \ {{ prettyprint* <prettyprint ;

: prettyprint-}} ( indent -- indent )
    prettyprint> \ }} prettyprint* ;

M: hashtable prettyprint* ( indent hashtable -- indent )
    hash>alist dup length 0 = [
        drop
        \ {{ prettyprint*
        " " write 
        \ }} prettyprint*
    ] [
        swap prettyprint-{{ swap prettyprint-list prettyprint-}}
    ] ifte ;

M: tuple prettyprint* ( indent tuple -- indent )
    \ << prettyprint*
    " " write
    tuple>list [ prettyprint-element ] each
    \ >> prettyprint* ;

: prettyprint-1 ( obj -- )
    0 swap prettyprint* drop ;

: prettyprint ( obj -- )
    prettyprint-1 terpri ;

: vocab-link ( vocab -- link )
    "vocabularies'" swap cat2 ;

: . ( obj -- )
    [
        "prettyprint-single-line" on
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

global [ 40 prettyprint-limit set ] bind
