! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays db2 db2.introspection db2.sqlite multiline
sequences ;
IN: db2.sqlite.introspection

M: sqlite-db-connection query-table-schema*
    1array
<"
SELECT sql FROM 
   (SELECT * FROM sqlite_master UNION ALL
    SELECT * FROM sqlite_temp_master)
WHERE type!='meta' and tbl_name = ?
ORDER BY tbl_name, type DESC, name
">
    sql-bind-query* first ;
