! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint

! This using kernel-internals is pretty bad. Remove the
! kernel-internals usage as soon as the tuple class is moved
! to the generic vocabulary.
USING: errors generic kernel kernel-internals lists math
namespaces stdio strings presentation unparser vectors words
hashtables ;

SYMBOL: prettyprint-limit
SYMBOL: one-line
SYMBOL: tab-size

GENERIC: prettyprint* ( indent obj -- indent )

M: object prettyprint* ( indent obj -- indent )
    unparse write ;

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
    tab-size get + one-line get [
        " " write
    ] [
        dup prettyprint-newline
    ] ifte ;

: prettyprint> ( indent -- indent )
    tab-size get - one-line get
    [ dup prettyprint-newline ] unless ;

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

: prettyprint-sequence ( indent start list end -- indent )
    #! Prettyprint a list, with start/end delimiters; eg, [ ],
    #! or { }, or << >>. The body of the list is indented,
    #! unless the list is empty.
    over [
        >r
        >r prettyprint* <prettyprint
        r> [ prettyprint-element ] each
        prettyprint> r> prettyprint*
    ] [
        >r >r prettyprint* " " write r> drop r> prettyprint*
    ] ifte ;

M: list prettyprint* ( indent list -- indent )
    \ [ swap \ ] prettyprint-sequence ;

M: cons prettyprint* ( indent cons -- indent )
    #! Here we turn the cons into a list of two elements.
    \ [[ swap uncons 2list \ ]] prettyprint-sequence ;

M: vector prettyprint* ( indent vector -- indent )
    \ { swap vector>list \ } prettyprint-sequence ;

M: hashtable prettyprint* ( indent hashtable -- indent )
    \ {{ swap hash>alist \ }} prettyprint-sequence ;

M: tuple prettyprint* ( indent tuple -- indent )
    \ << swap tuple>list \ >> prettyprint-sequence ;

: prettyprint-1 ( obj -- )
    0 swap prettyprint* drop ;

: prettyprint ( obj -- )
    prettyprint-1 terpri ;

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

global [ 40 prettyprint-limit set  4 tab-size set ] bind
