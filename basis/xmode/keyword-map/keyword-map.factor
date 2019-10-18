! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel strings assocs sequences hashtables
sorting unicode sets ;
IN: xmode.keyword-map

! Based on org.gjt.sp.jedit.syntax.KeywordMap
TUPLE: keyword-map no-word-sep ignore-case? assoc ;

: <keyword-map> ( ignore-case? -- map )
    keyword-map new
        swap >>ignore-case?
        H{ } clone >>assoc ;

: invalid-no-word-sep ( keyword-map -- ) f >>no-word-sep drop ;

: handle-case ( key keyword-map -- key assoc )
    [ ignore-case?>> [ >upper ] when ] [ assoc>> ] bi ;

M: keyword-map assoc-size
    assoc>> assoc-size ;

M: keyword-map at* handle-case at* ;

M: keyword-map set-at
    [ handle-case set-at ] [ invalid-no-word-sep ] bi ;

M: keyword-map clear-assoc
    [ assoc>> clear-assoc ] [ invalid-no-word-sep ] bi ;

M: keyword-map >alist
    assoc>> >alist ;

: (keyword-map-no-word-sep) ( assoc -- str )
    keys combine [ alpha? ] reject natural-sort ;

: keyword-map-no-word-sep* ( keyword-map -- str )
    dup no-word-sep>> [ ] [
        dup (keyword-map-no-word-sep) >>no-word-sep
        keyword-map-no-word-sep*
    ] ?if ;

INSTANCE: keyword-map assoc
