IN: postgresql
USING: alien compiler kernel parser sequences words ;

win32? [
	! PostgreSQL 7.5 will most likely support windows
    ! "postgresql" "dll" "stdcall" add-library
] [
    "postgresql" "libpq.so" "cdecl" add-library
] if

[
    "contrib/postgresql/libpq.factor"
    "contrib/postgresql/postgresql.factor"
    "contrib/postgresql/postgresql-test.factor"
    ! "contrib/postgresql/private.factor" ! put your password in this file
] [ run-file ] each

"postgresql" words [ try-compile ] each

