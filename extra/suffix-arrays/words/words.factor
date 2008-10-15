! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays math accessors sequences math.vectors
math.order sorting binary-search sets assocs fry suffix-arrays ;
IN: suffix-arrays.words

! to search on word names

: new-word-sa ( words -- sa )
    [ name>> ] map >suffix-array ;

: name>word-map ( words -- map )
    dup [ name>> V{ } clone ] H{ } map>assoc
    [ '[ dup name>> _ at push ] each ] keep ;

: query-word-sa ( map begin sa -- matches ) query '[ _ at ] map concat ;

! usage example :
! clear all-words 100 head dup name>word-map "test" rot new-word-sa query .
