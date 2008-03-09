USING: oracle oracle.liboci prettyprint tools.test
kernel ;

[
    "testuser" "testpassword" "//localhost/test1" log-on .

    allocate-statement-handle

    "CREATE TABLE TESTTABLE ( COL1 VARCHAR(40), COL2 NUMBER)" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "INSERT INTO TESTTABLE (COL1, COL2) VALUES('hello', 50)" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "INSERT INTO TESTTABLE (COL1, COL2) VALUES('hi', 60)" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "INSERT INTO TESTTABLE (COL1, COL2) VALUES('bye', 70)" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "COMMIT" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "SELECT * FROM TESTTABLE" prepare-statement

    1 SQLT_STR define-by-position run-query

    [ V{ "hello" "hi" "bye" "50" "60" "70" } ] [
    2 SQLT_STR define-by-position run-query gather-results
    ] unit-test

    clear-result

    "UPDATE TESTTABLE SET COL2 = 10 WHERE COL1='hi'" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "COMMIT" prepare-statement

    [ t ] [ execute-statement ] unit-test

    "SELECT * FROM TESTTABLE WHERE COL1 = 'hi'" prepare-statement

    [ V{ "10" } ] [
    2 SQLT_STR define-by-position run-query gather-results
    ] unit-test

    clear-result

    "DROP TABLE TESTTABLE" prepare-statement

    execute-statement

    free-statement-handle log-off clean-up terminate
] drop
