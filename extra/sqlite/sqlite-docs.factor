! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help sqlite help.syntax help.markup ;
IN: sqlite

HELP: sqlite-open 
{ $values { "filename" "path to sqlite database" } 
          { "db" "the database object" } 
}
{ $description "Opens the sqlite3 database." } 
{ $see-also sqlite-close sqlite-last-insert-rowid } ;

HELP: sqlite-close
{ $values { "db" "the database object" } 
}
{ $description "Closes the sqlite3 database." } 
{ $see-also sqlite-open sqlite-last-insert-rowid } ;

HELP: sqlite-last-insert-rowid
{ $values { "db" "the database object" } 
	  { "rowid" "the row number of the last insert" }
}
{ $description "Returns the number of the row of the last statement inserted into the database." } 
{ $see-also sqlite-open sqlite-close } ;

HELP: sqlite-prepare
{ $values { "db" "the database object" } 
	  { "sql" "the SQL statement as a string" }
	  { "statement" "the prepared SQL statement" }
}
{ $description "Internally compiles the SQL statement ready to be run by sqlite. The statement is executed and the results iterated over using " { $link sqlite-each } " and " { $link sqlite-map } ". The SQL statement can use named parameters which are later bound to values using " { $link sqlite-bind-text } " and " { $link sqlite-bind-text-by-name } "." } 
{ $see-also sqlite-open sqlite-close } ;

HELP: sqlite-bind-text
{ $values { "statement" "a prepared SQL statement" }
	  { "index" "the index of the bound parameter in the SQL statement" } 
	  { "text" "the string value to bind to that column" }
	  
}
{ $description "Binds the text to a parameter in the SQL statement. The parameter to be bound is identified by the index given and the indexes start from one." }
{ $examples { $code "\"people.db\" sqlite-open\n\"select * from people where name=?\" sqlite-prepare\n1 \"chris\" sqlite-bind-text" } }
{ $see-also sqlite-bind-text-by-name } ;

HELP: sqlite-bind-text-by-name
{ $values { "statement" "a prepared SQL statement" }
	  { "name" "the name of the bound parameter in the SQL statement" } 
	  { "text" "the string value to bind to that column" }
	  
}
{ $description "Binds the text to a parameter in the SQL statement. The parameter to be bound is identified by the given name." }
{ $examples { $code "\"people.db\" sqlite-open\n\"select * from people where name=:name\" sqlite-prepare\n\"name\" \"chris\" sqlite-bind-text" } }
{ $see-also sqlite-bind-text } ;

HELP: sqlite-finalize
{ $values { "statement" "a prepared SQL statement" }  
}
{ $description "Clean up all resources related to a statement. Once called the statement cannot be used again. All statements must be finalized before closing the database." }
{ $see-also sqlite-close sqlite-prepare } ;

HELP: sqlite-reset
{ $values { "statement" "a prepared SQL statement" }  
}
{ $description "Reset a statement so it can be called again, possibly with different bound parameters." }
{ $see-also sqlite-bind-text sqlite-bind-text-by-name } ;

HELP: column-count
{ $values { "statement" "a prepared SQL statement" } { "int" "the number of columns" } }
{ $description "Return the number of columns in each row of the result set of the given statement." }
{ $see-also column-text sqlite-each sqlite-map } ;

HELP: column-text
{ $values { "statement" "a prepared SQL statement" } { "index" "column number indexed from zero" } { "string" "column value" }
}
{ $description "Return the value of the given column, indexed from zero, as a string." }
{ $see-also column-count sqlite-each sqlite-map } ;

HELP: sqlite-each
{ $values { "statement" "a prepared SQL statement" } { "quot" "A quotation with stack effect ( statement -- )" }   
}
{ $description "Executes the SQL statement and for each returned row calls the qutotation passing the statement on the stack. The quotation can use " { $link column-text } " to get result values for that row." }
{ $see-also column-count column-text sqlite-map } ;

HELP: sqlite-map
{ $values { "statement" "a prepared SQL statement" } { "quot" "A quotation with stack effect ( statement -- value )" } { "seq" "a new sequence" }   
}
{ $description "Executes the SQL statement and for each returned row calls the qutotation passing the statement on the stack. The quotation can use " { $link column-text } " to get result values for that row. The quotation should leave a value on the stack which gets collected and returned in the resulting sequence." }
{ $see-also column-count column-text sqlite-each } ;
