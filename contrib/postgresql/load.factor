IN: scratchpad
USING: alien compiler kernel parser sequences words ;

"postgresql" "libpq" add-simple-library

{
    "libpq"
    "postgresql"
    "postgresql-test"
    ! "private" ! Put your password in this file
} [ "/contrib/postgresql/" swap ".factor" append3 run-resource ] each
