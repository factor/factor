IN: postgresql
USING: alien compiler kernel parser sequences words ;

win32? [
	! PostgreSQL 7.5 will most likely support windows
    ! "postgresql" "dll" "stdcall" add-library
] [
    "postgresql" "libpq.so" "cdecl" add-library
] ifte

[ "postgresql.factor" ]
[ "contrib/postgresql/" swap append run-file ] each

"postgresql" words [ try-compile ] each
