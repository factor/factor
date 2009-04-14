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
  { $example "\"mycollection\" <mdb-collection> t >>capped" } } ;

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
  { "query" "query assoc" }
  { "mdb-query" "mdb-query-msg instance" }
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
  { "update-msg" "mdb-update-msg instance" }
}
{ $description "" } ;

HELP: >upsert
{ $values
  { "mdb-update-msg" null }
  { "mdb-update-msg" null }
}
{ $description "" } ;

HELP: DIRTY?
{ $values
  
  { "value" null }
}
{ $description "" } ;

HELP: MDB-GENERAL-ERROR
{ $values
  
  { "value" null }
}
{ $description "" } ;

HELP: PARTIAL?
{ $values
  
  { "value" null }
}
{ $description "" } ;

HELP: asc
{ $values
  { "key" null }
  { "spec" null }
}
{ $description "" } ;

HELP: boolean
{ $var-description "" } ;

HELP: count
{ $values
  { "collection" null }
  { "query" null }
  { "result" null }
}
{ $description "" } ;

HELP: create-collection
{ $values
  { "name" null }
}
{ $description "" } ;

HELP: delete
{ $values
  { "collection" null }
  { "selector" null }
}
{ $description "" } ;

HELP: delete-unsafe
{ $values
  { "collection" null }
  { "selector" null }
}
{ $description "" } ;

HELP: desc
{ $values
  { "key" null }
  { "spec" null }
}
{ $description "" } ;

HELP: drop-collection
{ $values
  { "name" null }
}
{ $description "" } ;

HELP: drop-index
{ $values
  { "collection" null }
  { "name" null }
}
{ $description "" } ;

HELP: ensure-collection
{ $values
  { "collection" null }
  { "fq-collection" null }
}
{ $description "" } ;

HELP: ensure-index
{ $values
  { "collection" null }
  { "name" null }
  { "spec" null }
}
{ $description "" } ;

HELP: explain.
{ $values
  { "mdb-query" null }
}
{ $description "" } ;

HELP: find
{ $values
  { "mdb-query" null }
  { "cursor" null }
  { "result" null }
}
{ $description "" } ;

HELP: find-one
{ $values
  { "mdb-query" null }
  { "result" null }
}
{ $description "" } ;

HELP: get-more
{ $values
  { "mdb-cursor" null }
  { "mdb-cursor" null }
  { "objects" null }
}
{ $description "" } ;

HELP: hint
{ $values
  { "mdb-query" null }
  { "index-hint" null }
  { "mdb-query" null }
}
{ $description "" } ;

HELP: lasterror
{ $values
  
  { "error" null }
}
{ $description "" } ;

HELP: limit
{ $values
  { "mdb-query" null }
  { "limit#" null }
  { "mdb-query" null }
}
{ $description "" } ;

HELP: load-collection-list
{ $values
  
  { "collection-list" null }
}
{ $description "" } ;

HELP: load-index-list
{ $values
  
  { "index-list" null }
}
{ $description "" } ;

HELP: mdb-collection
{ $var-description "" } ;

HELP: mdb-cursor
{ $var-description "" } ;

HELP: mdb-error
{ $values
  { "id" null }
  { "msg" null }
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
  { "collection" null }
  { "assoc" assoc }
}
{ $description "" } ;

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

