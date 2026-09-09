USING: alien.c-types assocs db.sqlite.ffi debugger io kernel namespaces prettyprint
sequences system tools.test vocabs.loader words ;
IN: sqlite-optional-baseline
{ t } [ "sqlite3session_create" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ t } [ "sqlite3_carray_bind_v2" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ t } [ "sqlite3_preupdate_hook" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ 48 } [ fts5_api heap-size ] unit-test
