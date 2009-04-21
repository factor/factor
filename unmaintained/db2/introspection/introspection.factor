! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators constructors db2.connections
db2.sqlite.types kernel sequence-parser sequences splitting ;
IN: db2.introspection

TUPLE: table-schema table columns ;
CONSTRUCTOR: table-schema ( table columns -- table-schema ) ;

TUPLE: column name type modifiers ;
CONSTRUCTOR: column ( name type modifiers -- column ) ;

HOOK: query-table-schema* db-connection ( name -- table-schema )
HOOK: parse-create-statement db-connection ( name -- table-schema )

: parse-column ( string -- column )
    <sequence-parser> skip-whitespace
    [ " " take-until-sequence ]
    [ take-token sqlite-type>fql-type ]
    [ take-rest ] tri <column> ;

: parse-columns ( string -- seq )
    "," split [ parse-column ] map ;

M: object parse-create-statement ( string -- table-schema )
    <sequence-parser> {
        [ "CREATE TABLE " take-sequence* ]
        [ "(" take-until-sequence ]
        [ "(" take-sequence* ]
        [ take-rest [ CHAR: ) = ] trim-tail parse-columns ]
    } cleave <table-schema> ;

: query-table-schema ( name -- table-schema )
    query-table-schema* [ parse-create-statement ] map ;
