! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors html.elements io io.streams.string kernel namespaces semantic-db sequences strings tangle.path ;
IN: tangle.html

TUPLE: element attributes ;

TUPLE: ulist < element items ;
: <ulist> ( items -- element )
    H{ } clone swap ulist boa ;

TUPLE: link < element href text ;
: <link> ( href text -- element )
    H{ } clone -rot link boa ;

GENERIC: >html ( element -- str )

M: string >html ( str -- str ) ;

M: link >html ( link -- str )
    [ <a dup href>> =href a> text>> write </a> ] with-string-writer ;

M: node >html ( node -- str )
    dup node>path [
        swap node-content <link> >html
    ] [
        node-content
    ] if* ;

M: ulist >html ( ulist -- str )
    [
        <ul> items>> [ <li> >html write </li> ] each </ul>
    ] with-string-writer ;
