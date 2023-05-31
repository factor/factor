! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup threads ;

IN: odbc

HELP: odbc-init
{ $values { "env" "an ODBC environment handle" } }
{ $description
    "Initializes the ODBC driver manager and returns the "
    "environment handle required by " { $link odbc-connect } "."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-connect
{ $values
    { "env" "an ODBC environment handle" }
    { "dsn" "a string" }
    { "dbc" "an ODBC database connection handle" }
}
{ $description
    "Connects to the database identified by the ODBC data source name (DSN). "
    "The environment handle is usually obtained by a call to " { $link odbc-init } ". The result is the ODBC connection handle which can be used in other ODBC calls. When finished with the connection handle " { $link odbc-disconnect } " must be called on it."
}
{ $examples { $code "dbc get \"DSN=snowflake; UID=sheeple; PWD=sekrit\" odbc-connect" } }
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-disconnect
{ $values { "dbc" "an ODBC database connection handle" } }
{ $description
    "Disconnects from the given database."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-prepare
{ $values
    { "dbc" "an ODBC database connection handle" }
    { "string" "a string containing SQL" }
    { "statement" "an ODBC statement handle" }
}
{ $description
    "Prepares (precompiles) the given SQL string, ready for execution with " { $link odbc-execute } ". When finished with the statement " { $link odbc-free-statement } " must be called on it."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-free-statement
{ $values { "statement" "an ODBC statement handle" } }
{ $description
    "Closes the statement handle and frees up all resources associated with it."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-execute
{ $values { "statement" "an ODBC statement handle" } }
{ $description
    "Executes the statement. Once this is done " { $link odbc-next-row } " can be called to retrieve rows."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-next-row
{ $values
    { "statement" "an ODBC statement handle" }
    { "bool" "a boolean indicating success or failure" }
}
{ $description
    "Retrieves the next available row from the database. If no next row is available then " { $link f } " is returned. Once the row is retrieved " { $link odbc-number-of-columns } ", " { $link odbc-describe-column } ", " { $link odbc-get-field } " and " { $link odbc-get-row-fields } " can be used to query the data retrieved."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-number-of-columns
{ $values { "statement" "an ODBC statement handle" } { "number" "a number" } }
{ $description
    "Returns the number of columns of data retrieved."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-describe-column
{ $values
    { "statement" "an ODBC statement handle" }
    { "columnNumber" "a column number starting from one" }
    { "column" "a column object" }
}
{ $description
    "Retrieves column information for the given column number from the statement. The column number must be one or greater. The " { $link <column> } " object returned provides data type, name, etc."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-get-field
{ $values
    { "statement" "an ODBC statement handle" }
    { "column!" "a column number starting from one or a <column> object" }
    { "field" "a <field> object" }
}
{ $description
    "Returns a field object which contains the data for the field in the given column in the current row. The column can be identified by a number or a <column> object. The datatype of the contents of the field depends on the type of the column itself. Note that this word can only be safely called once on each column in a given row with most ODBC drivers. Subsequent calls on the same row for the same column can fail."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-get-row-fields
{ $values { "statement" "an ODBC statement handle" } { "seq" "a sequence" } }
{ $description
    "Returns a sequence of all field data for the current row. Note that this is not the <field> objects, but the data for that field. This word can only be called once on a given row. Subsequent calls on the same row may fail on some ODBC drivers."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-get-all-rows
{ $values { "statement" "an ODBC statement handle" } { "seq" "a sequence" } }
{ $description
    "Returns a sequence of all rows available from the statement. Effectively it is the contents of the entire query so may take some time and memory. Each element of the sequence is itself a sequence containing the data for that row. A " { $link yield } " is performed an various intervals so as to not lock up the Factor instance while it is running."
}
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-query
{ $values
    { "dsn" "a DSN string" }
    { "string" "a string containing SQL" }
    { "result" "a sequence" }
}
{ $description
    "This word initializes odbc, connects to the database with the given DSN, executes the query string and returns the result as a sequence. It cleans up all resources it uses. It is an inefficient way of running multiple queries but is useful for the occasional query, testing at the REPL, or as an example of how to do it."
}
{ $examples { $code "\"DSN=snowflake; UID=sheeple; PWD=sekrit\" \"select 1\" odbc-query" } }
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;

HELP: odbc-queries
{ $values
    { "dsn" "a DSN string" }
    { "strings" "a sequence of strings containing SQL" }
    { "results" "a sequence" }
}
{ $description
    "This word initializes odbc, connects to the database with the given DSN, executes the query strings and returns the result as a sequence. It cleans up all resources it uses."
}
{ $examples { $code "\"DSN=snowflake; UID=sheeple; PWD=sekrit\"
{ \"select 1\" \"select 2\" \"select 3\" } odbc-queries" } }
{ $see-also odbc-init odbc-connect odbc-disconnect odbc-prepare odbc-free-statement odbc-execute odbc-next-row odbc-number-of-columns odbc-describe-column odbc-get-field odbc-get-row-fields odbc-get-all-rows odbc-query } ;
