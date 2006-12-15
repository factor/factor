USING: kernel namespaces ;
IN: sql

GENERIC: execute-sql* ( string db -- )
GENERIC: query-sql* ( string db -- seq )

: execute-sql ( string -- ) db get execute-sql* ;
: query-sql ( string -- ) db get query-sql* ;


