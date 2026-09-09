USING: db.sqlite.ffi.release-tests environment kernel tools.test ;

f "SQLITE_3534_LIBRARY" [
    [ load-sqlite-fixture ]
    [ "Set SQLITE_3534_LIBRARY to the enabled 3.53.4 test library" = ] must-fail-with
] with-os-env
