! You will need to run  'createdb factor-test' to create the database.
! Set username and password in  the 'connect' word.

IN: postgresql-test
USING: kernel postgresql alien errors io ;


: connect ( -- PGconn )
	"localhost" "" "" "" "factor-test" "username" "password" PQsetdbLogin
	dup PQstatus 0 =
	[
		"couldn't connect to database" throw
	] unless ;

! For queries that do not return rows, PQexec() returns PGRES_COMMAND_OK.
! For queries that return rows, PQexec() returns PGRES_TUPLES_OK

: do-query ( PGconn query -- PGresult* )
	PQexec
	dup PQresultStatus PGRES_COMMAND_OK =
	over PQresultStatus PGRES_TUPLES_OK =
	or	
	[
		dup PQresultErrorMessage print
		"query failed" throw
	] unless ;

! 
: do-query-drop ( PGconn query -- PGresult * )
	do-query PQclear ; ! PQclear frees libpq.so memory

: do-query-drop-nofail ( PGconn query -- PGresult * )
	[ do-query ]
	[
		"non-fatal error, continuing" print
		drop
		PQclear ! clear memory
	] catch ;

! just a basic demo
: run-test ( -- )
	connect
	dup "drop table animal" do-query-drop-nofail
	dup "create table animal (id serial not null primary key, species varchar(256), name varchar(256), age integer)" do-query-drop-nofail
	dup "insert into animal (species, name, age) values ('lion', 'Mufasa', 5)" do-query-drop
	dup "select * from animal where name = 'Mufasa'" do-query
	dup PQntuples 1 = [ "...there can only be one Mufasa..." throw ] unless

	dup 0 0 PQgetvalue print
	dup 0 1 PQgetvalue print
	dup 0 2 PQgetvalue print
	dup 0 3 PQgetvalue print
	PQclear
	dup "insert into animal (species, name, age) values ('lion', 'Simba', 1)" do-query-drop
	dup "select * from animal" do-query
	! dup PQntuples >dec print
	PQclear
	PQfinish
	;

