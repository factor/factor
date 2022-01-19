! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.connections ;
IN: db2.introspection

HOOK: all-db-objects db-connection ( -- sequence )
HOOK: all-tables db-connection ( -- sequence )
HOOK: all-indices db-connection ( -- sequence )
HOOK: temporary-db-objects db-connection ( -- sequence )

HOOK: table-columns db-connection ( name -- sequence )


