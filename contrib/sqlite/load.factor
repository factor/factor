IN: scratchpad
USING: kernel alien parser compiler words sequences ;

"sqlite" "libsqlite3" add-simple-library

{
    "sqlite"
    "tuple-db"
    "test"
    "tuple-db-tests"
} [ "contrib/sqlite/" swap ".factor" append3 run-file ] each
