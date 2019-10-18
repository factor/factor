REQUIRES: libs/alien ;
USING: alien kernel ;

"sqlite" {
{ [ win32? ]  [ "sqlite3.dll" ] }
{ [ macosx? ] [ "sqlite3.dylib" ] }
{ [ unix?  ]  [ "libsqlite3.so" ] }
} cond "cdecl" add-library

PROVIDE: libs/sqlite
{ +files+ {
	"libsqlite.factor"
	"sqlite.factor"
	"sqlite.facts"
	"tuple-db.factor"
	"tuple-db.facts"
} }
{ +tests+ {
	"tuple-db-tests.factor"
} } ;
