! You will need to run  'createdb factor-test' to create the database.
! Set username and password in  the 'connect' word.

IN: postgresql-test
USING: kernel postgresql alien errors io prettyprint sequences namespaces ;

! just a basic demo
: run-test ( host str str str db user pass -- )
    [
	    "drop table animal" do-command

	    "create table animal (id serial not null primary key, species varchar(256), name varchar(256), age integer)" do-command
	    "insert into animal (species, name, age) values ('lion', 'Mufasa', 5)" do-command
	    "select * from animal where name = 'Mufasa'" [ ] do-query
	    "select * from animal where name = 'Mufasa'"
        [
	        result>seq length 1 = [ "...there can only be one Mufasa..." throw ] unless
        ] do-query
	    "insert into animal (species, name, age) values ('lion', 'Simba', 1)" do-command

	    "select * from animal" 
        [
              "Animal table:" print
              result>seq print-table
        ] do-query

        ! intentional errors
        ! [ "select asdf from animal"
        ! [ ] do-query ] catch [ "caught: " write print ] when*
        ! "select asdf from animal" [ ] do-query 
        ! "aofijweafew" do-command
    ] with-postgres-catch ;

