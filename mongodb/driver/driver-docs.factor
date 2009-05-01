! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel quotations ;
IN: mongodb.driver

HELP: <mdb-collection>
{ $values
  { "name" "name of the collection" }
  { "collection" "mdb-collection instance" }
}
{ $description "Creates a new mdb-collection instance. Use this to create capped/limited collections. See also: " { $link mdb-collection } }
{ $examples
  { $example "! creates a mdb-collection instance capped to a maximum of 1000000 entries"
    "\"mycollection\" <mdb-collection> t >>capped 1000000 >>max" } } ;

HELP: <mdb>
{ $values
  { "db" "name of the database to use" }
  { "host" "host name or IP address" }
  { "port" "port number" }
  { "mdb" "mdb-db instance" }
}
{ $description "Create a new mdb-db instance and automatically resolves master/slave information in a paired MongoDB setup." }
{ $examples
  { $example "\"db\" \"127.0.0.1\" 27017 <mdb>" } } ;

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
  { $example "\"mycollection\" H{ } <query>" } } ;

HELP: <update>
{ $values
  { "collection" "collection to update" }
  { "selector" "selector assoc (selects which object(s) to update" }
  { "object" "updated object or update instruction" }
  { "mdb-update-msg" "mdb-update-msg instance" }
}
{ $description "Creates an update message for the object(s) identified by the given selector."
  "MongoDB supports full object updates as well as partial update modifiers such as $set, $inc or $push"
  "For more information see: " { $url "http://www.mongodb.org/display/DOCS/Updates" } } ;

HELP: >upsert
{ $values
  { "mdb-update-msg" "a mdb-update-msg" }
  { "mdb-update-msg" "mdb-update-msg with the upsert indicator set to t" }
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
  { "name" "collection name" }
}
{ $description "Creates a new collection with the given name." } ;

HELP: delete
{ $values
  { "collection" "a collection" }
  { "selector" "assoc which identifies the objects to be removed from the collection" }
}
{ $description "removes objects from the collection (with lasterror check)" } ;

HELP: delete-unsafe
{ $values
  { "collection" "a collection" }
  { "selector" "assoc which identifies the objects to be removed from the collection" }
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
  { "collection" "a collection; e.g. mycollection " }
  { "fq-collection" "full qualified collection name; e.g. db.mycollection" }
}
{ $description "ensures that the collection exists in the database and returns its full qualified name" } ;

HELP: ensure-index
{ $values
  { "collection" "a collection" }
  { "name" "index name" }
  { "spec" "index spec" }
}
{ $description "Ensures the existence of the given index. "
  "For more information on MongoDB indexes see: " { $url "http://www.mongodb.org/display/DOCS/Indexes" } }
{ $examples
  { $example "\"mycollection\" nameIdx [ \"name\" asc ] keyspec <index-spec> ensure-index" }
  { $example "\"mycollection\" nameIdx [ \"name\" asc ] keyspec <index-spec> unique-index ensure-index" } } ;

HELP: explain.
{ $values
  { "mdb-query-msg" "a query message" }
}
{ $description "Prints the execution plan for the given query" } ;

HELP: find
{ $values
  { "mdb-query" "a query" }
  { "cursor" "a cursor (if there are more results) or f" }
  { "result" "a sequences of objects" }
}
{ $description "executes the given query" }
{ $examples
  { $example "\"mycollection\" H{ { \"name\" \"Alfred\" } } <query> find " } } ;

HELP: find-one
{ $values
  { "mdb-query" "a query" }
  { "result" "a single object or f" }
}
{ $description "Executes the query and returns one object at most" } ;

HELP: hint
{ $values
  { "mdb-query" "a query" }
  { "index-hint" "a hint to an index" }
  { "mdb-query" "modified query object" }
}
{ $description "Annotates the query with a hint to an index. "
  "For detailed information see: " { $url "http://www.mongodb.org/display/DOCS/Optimizing+Mongo+Performance#OptimizingMongoPerformance-Hint" } }
{ $examples
  { $example "\"mycollection\" H{ { \"name\" \"Alfred\" } { \"age\" 70 } } <query> H{ { \"name\" 1 } } hint find" } } ;

HELP: lasterror
{ $values
  
  { "error" "error message or f" }
}
{ $description "Checks if the last operation resulted in an error on the MongoDB side"
  "For more information see: " { $url "http://www.mongodb.org/display/DOCS/Mongo+Commands#MongoCommands-LastErrorCommands" } } ;

HELP: limit
{ $values
  { "mdb-query" "a query" }
  { "limit#" "number of objects that should be returned at most" }
  { "mdb-query" "modified query object" }
}
{ $description "Limits the number of returned objects to limit#" }
{ $examples
  { $example "\"mycollection\" H{ } <query> 10 limit find" } } ;

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
{ $var-description "" } ;

HELP: mdb-cursor
{ $var-description "" } ;

HELP: mdb-error
{ $values
  { "msg" "error message" }
}
{ $description "" } ;

HELP: r/
{ $values
  { "token" null }
  { "mdbregexp" null }
}
{ $description "" } ;

HELP: save
{ $values
  { "collection" "a collection" }
  { "assoc" "object" }
}
{ $description "Saves the object to the given collection."
  " If the object contains a field name \"_id\" this command automatically performs an update (with upsert) instead of a plain save" } ;

HELP: save-unsafe
{ $values
  { "collection" null }
  { "object" object }
}
{ $description "" } ;

HELP: skip
{ $values
  { "mdb-query" null }
  { "skip#" null }
  { "mdb-query" null }
}
{ $description "" } ;

HELP: sort
{ $values
  { "mdb-query" null }
  { "quot" quotation }
  { "mdb-query" null }
}
{ $description "" } ;

HELP: update
{ $values
  { "mdb-update-msg" null }
}
{ $description "" } ;

HELP: update-unsafe
{ $values
  { "mdb-update-msg" null }
}
{ $description "" } ;

HELP: validate.
{ $values
  { "collection" null }
}
{ $description "" } ;

HELP: with-db
{ $values
  { "mdb" null }
  { "quot" quotation }
}
{ $description "" } ;

ARTICLE: "mongodb.driver" "mongodb.driver"
{ $vocab-link "mongodb.driver" }
;

ABOUT: "mongodb.driver"

