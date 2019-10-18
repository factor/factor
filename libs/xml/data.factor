USING: kernel generic ;
IN: xml-data

TUPLE: name space tag url ;

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    [ name-space swap name-space ?= ] 2keep
    [ name-url swap name-url ?= ] 2keep
    name-tag swap name-tag ?= and and ;

TUPLE: entity name ;
TUPLE: opener name props ;
TUPLE: closer name ;
TUPLE: contained name props ;
TUPLE: comment text ;
TUPLE: directive text ;
TUPLE: instruction text ;
TUPLE: prolog version encoding standalone ;

TUPLE: xml-doc prolog before after ;
C: xml-doc ( prolog before main after -- xml-doc )
    [ set-xml-doc-after ] keep
    [ set-delegate ] keep
    [ set-xml-doc-before ] keep
    [ set-xml-doc-prolog ] keep ;

TUPLE: tag props children ;
C: tag ( name props children -- tag )
    [ set-tag-children ] keep
    [ set-tag-props ] keep
    [ set-delegate ] keep ;

! tag with children=f is contained
: <contained-tag> ( name props -- tag )
    f <tag> ;

PREDICATE: tag contained-tag tag-children not ;
PREDICATE: tag open-tag tag-children ;
