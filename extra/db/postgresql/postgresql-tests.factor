! You will need to run  'createdb factor-test' to create the database.
! Set username and password in  the 'connect' word.

USING: kernel db.postgresql alien continuations io prettyprint
sequences namespaces tools.test ;
IN: temporary

: test-connection ( host port pgopts pgtty db user pass -- bool )
    [ [ ] with-postgres ] catch "Error connecting!" "Connected!" ? print ;

[ ] [ "localhost" "" "" "" "factor-test" "postgres" "" test-connection ] unit-test

[ ] [ "localhost" "postgres" "" "factor-test" <postgresql-db> [ ] with-db ] unit-test

! just a basic demo

"localhost" "postgres" "" "factor-test" <postgresql-db> [
    [ ] [ "drop table animal" do-command ] unit-test

    [ ] [ "create table animal (id serial not null primary key, species varchar(256), name varchar(256), age integer)" do-command ] unit-test
    
    [ ] [ "insert into animal (species, name, age) values ('lion', 'Mufasa', 5)"
    do-command ] unit-test

    [ ] [ "select * from animal where name = 'Mufasa'" [ ] do-query ] unit-test
    [ ] [ "select * from animal where name = 'Mufasa'" [
            result>seq length 1 = [
                "...there can only be one Mufasa..." throw
            ] unless
        ] do-query
    ] unit-test

    [ ] [ "insert into animal (species, name, age) values ('lion', 'Simba', 1)"
    do-command ] unit-test

    [ ] [
        "select * from animal" 
        [
            "Animal table:" print
            result>seq print-table
        ] do-query
    ] unit-test

    ! intentional errors
    ! [ "select asdf from animal"
    ! [ ] do-query ] catch [ "caught: " write print ] when*
    ! "select asdf from animal" [ ] do-query 
    ! "aofijweafew" do-command
] with-db


"localhost" "postgres" "" "factor-test" <postgresql-db> [
    [ ] [ "drop table animal" do-command ] unit-test
] with-db
