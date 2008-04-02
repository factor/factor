! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.predicate kernel namespaces parser quotations
sequences words prettyprint prettyprint.backend prettyprint.sections
compiler.units classes ;
IN: classes.singleton

PREDICATE: singleton < predicate-class
    [ "predicate-definition" word-prop ]
    [ [ eq? ] curry ] bi sequence= ;

: define-singleton ( token -- )
    create-class-in
    dup save-location
    \ singleton
    over [ eq? ] curry define-predicate-class ;

M: singleton see-class* ( class -- )
    <colon \ SINGLETON: pprint-word pprint-word ;
