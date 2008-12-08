! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators alien alien.strings alien.syntax
prettyprint.backend prettyprint.custom prettyprint.sections ;
IN: alien.prettyprint

M: alien pprint*
    {
        { [ dup expired? ] [ drop \ BAD-ALIEN pprint-word ] }
        { [ dup pinned-c-ptr? not ] [ drop "( displaced alien )" text ] }
        [ \ ALIEN: [ alien-address pprint* ] pprint-prefix ]
    } cond ;

M: dll pprint* dll-path dup "DLL\" " "\"" pprint-string ;
