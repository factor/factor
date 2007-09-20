! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help sqlite sqlite.tuple-db help.syntax help.markup ;

ARTICLE: { "sqlite" "tuple-db-loading" } "Loading"
"The quickest way to get up and running with this library is to load it as a module:"
{ $code "\"libs/sqlite\" require\nUSE: sqlite\nUSE: tuple-db\n" } 
"Some simple tests can be run to check that everything is working ok:"
{ $code "\"libs/sqlite\" test-module" } ;

ARTICLE: { "sqlite" "tuple-db-usage" } "Basic Usage"
"This library can be used for storing simple Factor tuples in a sqlite database. In its current form the tuples must not contain references to other tuples and should not have a delegate set."
$nl
"This document will use the following tuple for demonstration purposes:"
{ $code "TUPLE: person name surname phone ;" }
"The sqlite database to store tuples must be created, or an existing one opened. This is done using the " { $link sqlite-open } " word. If the database does not exist then it is created. The examples in this document store the database pointer in a variable called 'db':"
{ $code "SYMBOL: db\n\"example.db\" sqlite-open db set-global" } ;

ARTICLE: { "sqlite" "tuple-db-mappings" } "Tuple Mappings"
"Each tuple has a 'mapping' tuple associated with it. The 'mapping' stores information about what table the tuple will be stored in, the datatypes of the tuple slots, etc. A mapping must be created before a tuple can be stored in a database. A default mapping is easily created using " { $link default-mapping } ". Given the tuple class, this will use reflection to get the slots of it, assume that all slots are of database type 'text', and store the tuple objects in a table with the same name as the tuple."
$nl
"The following shows how to create the default mapping for the 'person' tuple, and how to register that mapping so the 'tuple-db' system can know how to handle 'person' instances:"
{ $code "person default-mapping set-mapping" } ;

ARTICLE: { "sqlite" "tuple-db-create" } "Creating the table"
"The table used to store tuple instances may need to be created. This can be done manually using the external sqlite program or via " { $link create-tuple-table } ":"
{ $code "db get person create-tuple-table" }
"The SQL used to create the table is produced internally by " { $link create-sql } ". This is a generic word dispatched on the mapping object, and could be specialised if needed. If you wish to see the SQL used to create the table, use the following code:"
{ $code "person get-mapping create-sql .\n => \"create table person (name text,surname text,phone text);\"" } ;

ARTICLE: { "sqlite" "tuple-db-insert" } "Inserting instances"
"The " { $link insert-tuple } " word will store instances of a tuple into the database table defined by its mapping object:"
{ $code "db get \"John\" \"Smith\" \"123-456-789\" <person> insert-tuple" }
{ $link insert-tuple } " internally uses the " { $link insert-sql } " word to produce the SQL used to store the tuple. Like " { $link create-sql } ", it is a generic word specialized on the mapping object. You can call it directly to see what SQL is generated:"
{ $code "person get-mapping insert-sql .\n => \"insert into person values(:name,:surname,:phone);\"" }
"Notice that the SQL uses named parameters. These parameters are bound to the values stored in the tuple object when the SQL is compiled. This helps prevent SQL injection techniques."
$nl
"When " { $link insert-sql } " is run, it adds a delegate to the tuple being stored. The delegate is of type 'persistent' and holds the row id of the tuple in its 'key' slot. This way the exact record can be updated or retrieved later. The following demonstates this fact:"
{ $code "\"Mandy\" \"Jones\" \"987-654-321\" <person> dup .\n  => T{ person f \"Mandy\" \"Jones\" \"987-654-321\" }\ndb get over insert-tuple .\n  => T{ person T{ persistent ... 2 } \"Mandy\" \"Jones\" \"987-654-321\" }" }
"The '2' in the above example is the row id of the record inserted. We can go into the 'sqlite' command and view this record:"
{ $code "  $ sqlite3 example.db\n    SQLite version 3.0.8\n    Enter \".help\" for instructions\n    sqlite> select ROWID,* from person;\n      1|John|Smith|123-456-789\n      2|Mandy|Jones|987-654-321\n    sqlite>" } ;

ARTICLE: { "sqlite" "tuple-db-finding" } "Finding instances"
"The " { $link find-tuples } " word is used to return tuples populated with data already existing in the database. As well as the database objcet, it takes a tuple that should be populated only with the fields that should be matched in the database. All fields you do not wish to match against should be set to 'f':"
{ $code "db get f \"Smith\" f <person> find-tuples .\n => { T{ person # \"John\" \"Smith\" \"123-456-789\" } }\ndb get \"Mandy\" f f <person> find-tuples .\n => { T{ person # \"Mandy\" \"Jones\" \"987-654-321\" } }\ndb get \"Joe\" f f <person> find-tuples .\n => { }" }
"Notice that if no matching tuples are found then an empty sequence is returned. The returned tuples also have their delegate set to 'persistent' with the correct row id set as the key. This can be used to later update the tuples with new information and store them in the database." ;

ARTICLE: { "sqlite" "tuple-db-updating" } "Updating instances"
"Given a tuple that has the 'persistent' delegate with the row id set as the key, you can update this specific record using " { $link update-tuple } ":"
{ $code "db get f \"Smith\" f <person> find-tuples dup .\n => { T{ person # \"John\" \"Smith\" \"123-456-789\" } }\nfirst { \"999-999-999\" swap set-person-phone ] keep dup .\n => T{ person T{ persistent f # \"1\" } \"John\" \"Smith\" \"999-999-999\" ...\n db get swap update-tuple" }
"Using the 'sqlite' command from the system shell you can see the record was updated:"
{ $code "  $ sqlite3 example.db\n    SQLite version 3.0.8\n    Enter \".help\" for instructions\n    sqlite> select ROWID,* from person;\n      1|John|Smith|999-999-999\n      2|Mandy|Jones|987-654-321\n    sqlite>" } ;

ARTICLE: { "sqlite" "tuple-db-inserting-or-updating" } "Inserting or Updating instances"
"The " { $link save-tuple } " word can be used to insert a tuple if it has not already been stored in the database, or update it if it already exists. Whether to insert or update is decided by the existance of the 'persistent' delegate:"
{ $code "\"Mary\" \"Smith\" \"111-111-111\" <person> dup .\n  => T{ person f \"Mary\" \"Smith\" \"111-111-111\" }\n! This will insert the tuple\ndb get over save-tuple dup .\n  => T{ person T{ persistent f # \"3\" } \"Mary\" \"Smith\" \"111-111-111\" ...\n[ \"222-222-222\" swap set-person-phone ] keep dup .\n  => T{ person T{ persistent f # \"3\" } \"Mary\"  \"Smith\" \"222-222-222\" ...\n! This will update the tuple\ndb get over save-tuple .\n  => T{ person T{ persistent f # \"3\" } \"Mary\"  \"Smith\" \"222-222-222\" ..." } ;

ARTICLE: { "sqlite" "tuple-db-deleting" } "Deleting instances"
"Given a tuple with the delegate set to 'persistent' (ie. One already stored in the database) you can delete it from the database with " { $link delete-tuple } ":"
{ $code "db get f \"Smith\" f <person> find-tuples [ db get swap delete-tuple ] each" } ;

ARTICLE: { "sqlite" "tuple-db-closing" } "Closing the database"
"It's important to close the sqlite database when you've finished using it. The word for this is " { $link sqlite-close } ":"
{ $code "db get sqlite-close" } ;

ARTICLE: { "sqlite" "tuple-db" } "Tuple Database Library"
"The version of sqlite required by this library is version 3 or greater. This library allows storing Factor tuples in a sqlite database. It provides words to create, read update and delete these entries as well as simple searching."
$nl
"The library is in a very early state and is likely to change quite a bit in the near future. Its most notable omission is it cannot currently handle relationships between tuples." 
{ $subsection { "sqlite" "tuple-db-loading" } } 
{ $subsection { "sqlite" "tuple-db-usage" } } 
{ $subsection { "sqlite" "tuple-db-mappings" } } 
{ $subsection { "sqlite" "tuple-db-create" } } 
{ $subsection { "sqlite" "tuple-db-insert" } } 
{ $subsection { "sqlite" "tuple-db-finding" } } 
{ $subsection { "sqlite" "tuple-db-updating" } } 
{ $subsection { "sqlite" "tuple-db-inserting-or-updating" } } 
{ $subsection { "sqlite" "tuple-db-deleting" } } 
{ $subsection { "sqlite" "tuple-db-closing" } } 
;

HELP: default-mapping 
{ $values { "class" "symbol for the tuple class" } 
          { "mapping" "a mapping object" } 
}
{ $description "Given a tuple class, create a default mappings object. This is used to associate field names in the tuple with SQL statement field names, etc." } 
{ $see-also { "sqlite" "tuple-db" } set-mapping } ;

HELP: set-mapping 
{ $values { "mapping" "a mapping object" } 
}
{ $description "Store a database mapping so that the tuple-db system knows how to store instances of the tuple in the database." } 
{ $see-also { "sqlite" "tuple-db" } default-mapping } ;

HELP: create-tuple-table
{ $values { "db" "a database object" } { "class" "symbol for the tuple class" }
}
{ $description "Create the database table to store intances of the given tuple." } 
{ $see-also { "sqlite" "tuple-db" } default-mapping get-mapping } ;

HELP: insert-tuple
{ $values { "db" "a database object" } { "tuple" "an instance of a tuple" }
}
{ $description "Insert the tuple instance into the database. It is assumed that this tuple does not currently exist in the database." } 
{ $see-also { "sqlite" "tuple-db" } insert-tuple update-tuple find-tuples delete-tuple save-tuple } ;

HELP: find-tuples
{ $values { "db" "a database object" } { "tuple" "an instance of a tuple" } { "seq" "a sequence of tuples" } }
{ $description "Return a sequence of all tuples in the database that match the tuple provided as a template. All fields in the tuple must match the entries in the database, except for those set to 'f'." } 
{ $see-also { "sqlite" "tuple-db" } insert-tuple update-tuple find-tuples delete-tuple save-tuple } ;

HELP: update-tuple
{ $values { "db" "a database object" } { "tuple" "an instance of a tuple" }
}
{ $description "Update the database record for this tuple instance. The tuple must have previously been obtained from the database, or inserted into it. It must have a delegate of 'persistent' with the key field set (which is done by the find and insert operations)." } 
{ $see-also { "sqlite" "tuple-db" } insert-tuple update-tuple find-tuples delete-tuple save-tuple } ;

HELP: save-tuple
{ $values { "db" "a database object" } { "tuple" "an instance of a tuple" }
}
{ $description "Insert or Update the tuple instance depending on whether it has a persistent delegate." } 
{ $see-also { "sqlite" "tuple-db" } insert-tuple update-tuple find-tuples delete-tuple save-tuple } ;

HELP: delete-tuple
{ $values { "db" "a database object" } { "tuple" "an instance of a tuple" }
}
{ $description "Delete this tuple instance from the database. The tuple must have previously been obtained from the database, or inserted into it. It must have a delegate of 'persistent' with the key field set (which is done by the find and insert operations)." } 
{ $see-also { "sqlite" "tuple-db" } insert-tuple update-tuple find-tuples delete-tuple save-tuple } ;
