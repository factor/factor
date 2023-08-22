! Copyright (C) 2009 Sascha Matzke.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel quotations ;
IN: mongodb.driver

HELP: <mdb-collection>
{ $values
  { "name" "name of the collection" }
  { "collection" "mdb-collection instance" }
}
{ $examples { $unchecked-example "USING: mongodb.driver ;" "\"mycollection\" <mdb-collection> t >>capped 1000000 >>max" "" } }
{ $description "Creates a new mdb-collection instance. Use this to create capped/limited collections." } ;

HELP: <mdb>
{ $values
  { "db" "name of the database to use" }
  { "host" "host name or IP address" }
  { "port" "port number" }
  { "mdb" "mdb-db instance" }
}
{ $description "Create a new mdb-db instance and automatically resolves master/slave information in a paired MongoDB setup." }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;" "\"db\" \"127.0.0.1\" 27017 <mdb>" "" } } ;

HELP: <query>
{ $values
  { "collection" "collection to query" }
  { "assoc" "query assoc" }
  { "mdb-query-msg" "mdb-query-msg instance" }
}
{ $description "Creates a new mdb-query-msg instance. "
  "This word must be called from within a with-db scope."
  "For more see: "
  { $link with-db } }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;" "\"mycollection\" H{ } <query>" "" } } ;

HELP: <update>
{ $values
  { "collection" "collection to update" }
  { "selector" "selector assoc (selects which object(s) to update" }
  { "object" "updated object or update instruction" }
  { "mdb-update-msg" "mdb-update-msg instance" }
}
{ $description "Creates an update message for the object(s) identified by the given selector."
  "MongoDB supports full object updates as well as partial update modifiers such as $set, $inc or $push"
  "For more information see: " { $url "https://www.mongodb.org/display/DOCS/Updates" } } ;

HELP: >upsert
{ $values
  { "mdb-update-msg" "a mdb-update-msg" }
}
{ $description "Marks a mdb-update-msg as upsert operation"
  "(inserts object identified by the update selector if it doesn't exist in the collection)" } ;

HELP: PARTIAL?
{ $values
  { "value" "partial?" }
}
{ $description "key which refers to a partially loaded object" } ;

HELP: asc
{ $values
  { "key" "sort key" }
  { "spec" "sort spec" }
}
{ $description "indicates that the values of the specified key should be sorted in ascending order" } ;

HELP: count
{ $values
  { "mdb-query-msg" "query" }
  { "result" "number of objects in the collection that match the query" }
}
{ $description "count objects in a collection" } ;

HELP: create-collection
{ $values
  { "name/collection" "collection name" }
}
{ $description "Creates a new collection with the given name." } ;

HELP: delete
{ $values
  { "mdb-delete-msg" "a delete msg" }
}
{ $description "removes objects from the collection (with lasterror check)" } ;

HELP: delete-unsafe
{ $values
  { "mdb-delete-msg" "a delete msg" }
}
{ $description "removes objects from the collection (without error check)" } ;

HELP: desc
{ $values
  { "key" "sort key" }
  { "spec" "sort spec" }
}
{ $description "indicates that the values of the specified key should be sorted in descending order" } ;

HELP: drop-collection
{ $values
  { "name" "a collection" }
}
{ $description "removes the collection and all objects in it from the database" } ;

HELP: drop-index
{ $values
  { "collection" "a collection" }
  { "name" "an index name" }
}
{ $description "drops the specified index from the collection" } ;

HELP: ensure-collection
{ $values
  { "name" "a collection; e.g. mycollection " }
}
{ $description "ensures that the collection exists in the database" } ;

HELP: ensure-index
{ $values
  { "index-spec" "an index specification" }
}
{ $description "Ensures the existence of the given index. "
  "For more information on MongoDB indexes see: " { $url "https://www.mongodb.org/display/DOCS/Indexes" } }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;"
    "\"db\" \"127.0.0.1\" 27017 <mdb>"
    "[ \"mycollection\" nameIdx [ \"name\" asc ] keyspec <index-spec> ensure-index ] with-db" "" }
  { $unchecked-example "USING: mongodb.driver ;"
    "\"db\" \"127.0.0.1\" 27017 <mdb>" "[ \"mycollection\" nameIdx [ \"name\" asc ] keyspec <index-spec> t >>unique? ensure-index ] with-db" "" } } ;

HELP: explain.
{ $values
  { "mdb-query-msg" "a query message" }
}
{ $description "Prints the execution plan for the given query" } ;

HELP: find
{ $values
  { "selector" "a mdb-query or mdb-cursor" }
  { "mdb-cursor/f" "a cursor (if there are more results) or f" }
  { "seq" "a sequences of objects" }
}
{ $description "executes the given query" }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;"
    "\"db\" \"127.0.0.1\" 27017 <mdb>"
    "[ \"mycollection\" H{ { \"name\" \"Alfred\" } } <query> find ] with-db" "" } } ;

HELP: find-one
{ $values
  { "mdb-query-msg" "a query" }
  { "result/f" "a single object or f" }
}
{ $description "Executes the query and returns one object at most" } ;

HELP: hint
{ $values
  { "mdb-query-msg" "a query" }
  { "index-hint" "a hint to an index" }
}
{ $description "Annotates the query with a hint to an index. "
  "For detailed information see: " { $url "https://www.mongodb.org/display/DOCS/Optimizing+Mongo+Performance#OptimizingMongoPerformance-Hint" } }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;"
    "\"db\" \"127.0.0.1\" 27017 <mdb>"
    "[ \"mycollection\" H{ { \"name\" \"Alfred\" } { \"age\" 70 } } <query> H{ { \"name\" 1 } } hint find ] with-db" "" } } ;

HELP: lasterror
{ $values

  { "error" "error message or f" }
}
{ $description "Checks if the last operation resulted in an error on the MongoDB side"
  "For more information see: " { $url "https://www.mongodb.org/display/DOCS/Mongo+Commands#MongoCommands-LastErrorCommands" } } ;

HELP: limit
{ $values
  { "mdb-query-msg" "a query" }
  { "limit#" "number of objects that should be returned at most" }
}
{ $description "Limits the number of returned objects to limit#" }
{ $examples
  { $unchecked-example "USING: mongodb.driver ;"
    "\"db\" \"127.0.0.1\" 27017 <mdb>"
    "[ \"mycollection\" H{ } <query> 10 limit find ] with-db" "" } } ;

HELP: load-collection-list
{ $values

  { "collection-list" "list of collections in the current database" }
}
{ $description "Returns a list of all collections that exist in the current database" } ;

HELP: load-index-list
{ $values

  { "index-list" "list of indexes" }
}
{ $description "Returns a list of all indexes that exist in the current database" } ;

HELP: mdb-collection
{ $var-description "MongoDB collection" } ;

HELP: mdb-cursor
{ $var-description "MongoDB cursor" } ;

HELP: mdb-error
{ $values
  { "msg" "error message" }
}
{ $description "error class" } ;

HELP: r/
{ $values
  { "token" "a regexp string" }
  { "mdbregexp" "a mdbregexp tuple instance" }
}
{ $description "creates a new mdbregexp instance" } ;

HELP: save
{ $values
  { "collection" "a collection" }
  { "assoc" "object" }
}
{ $description "Saves the object to the given collection."
  " If the object contains a field name \"_id\" this command automatically performs an update (with upsert) instead of a plain save" } ;

HELP: save-unsafe
{ $values
  { "collection" "a collection" }
  { "assoc" "object" }
}
{ $description "Save the object to the given collection without automatic error check" } ;

HELP: skip
{ $values
  { "mdb-query-msg" "a query message" }
  { "skip#" "number of objects to skip" }
}
{ $description "annotates a query message with a number of objects to skip when returning the results" } ;

HELP: sort
{ $values
  { "mdb-query-msg" "a query message" }
  { "sort-quot" "a quotation with sort specifiers" }
}
{ $description "annotates the query message for sort specifiers" } ;

HELP: update
{ $values
  { "mdb-update-msg" "a mdb-update message" }
}
{ $description "performs an update" } ;

HELP: update-unsafe
{ $values
  { "mdb-update-msg" "a mdb-update message" }
}
{ $description "performs an update without automatic error check" } ;

HELP: validate.
{ $values
  { "collection" "collection to validate" }
}
{ $description "validates the collection" } ;

HELP: with-db
{ $values
  { "mdb" "mdb instance" }
  { "quot" "quotation to execute with the given mdb instance as context" }
}
{ $description "executes a quotation with the given mdb instance in its context" } ;
