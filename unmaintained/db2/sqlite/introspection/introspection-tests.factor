! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.connections db2.introspection
db2.sqlite.introspection db2.tester db2.types tools.test ;
IN: db2.sqlite.introspection.tests


: test-sqlite-introspection ( -- )
    [
        {
            T{ table-schema
                { table "computer" }
                { columns
                    {
                        T{ column
                            { name "name" }
                            { type VARCHAR }
                            { modifiers "" }
                        }
                        T{ column
                            { name "os" }
                            { type VARCHAR }
                            { modifiers "" }
                        }
                    }
                }
            }
        }
    ] [
        
        sqlite-test-db [
            "computer" query-table-schema
        ] with-db
    ] unit-test

    ;

[ test-sqlite-introspection ] test-sqlite
