! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: db2.types

SINGLETONS: +db-assigned-id+ +user-assigned-id+ +random-id+ ;
UNION: +primary-key+ +db-assigned-id+ +user-assigned-id+ +random-id+ ;

SYMBOLS: +autoincrement+ +serial+ +unique+ +default+ +null+ +not-null+
+foreign-id+ +has-many+ +on-update+ +on-delete+ +restrict+ +cascade+
+set-null+ +set-default+ ;

SINGLETONS: INTEGER BIG-INTEGER SIGNED-BIG-INTEGER UNSIGNED-BIG-INTEGER
DOUBLE REAL BOOLEAN TEXT VARCHAR DATE TIME DATETIME TIMESTAMP BLOB
FACTOR-BLOB NULL URL ;

ERROR: no-sql-type type ;
