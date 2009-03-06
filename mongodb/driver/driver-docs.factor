! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel quotations ;
IN: mongodb.driver

HELP: <mdb-collection>
{ $values
     { "name" null }
     { "collection" null }
}
{ $description "" } ;

HELP: <mdb-cursor>
{ $values
     { "id" null } { "collection" null } { "return#" null }
     { "cursor" null }
}
{ $description "" } ;

HELP: <mdb>
{ $values
     { "db" null } { "host" null } { "port" null }
     { "mdb" null }
}
{ $description "" } ;

HELP: <query>
{ $values
     { "collection" "the collection to be queried" } { "query" "query" }
     { "mdb-query" "mdb-query-msg tuple instance" }
}
{ $description "create a new query instance" } ;

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
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: count
{ $values
     { "collection" null } { "query" null }
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
     { "collection" null } { "selector" null }
}
{ $description "" } ;

HELP: delete-unsafe
{ $values
     { "collection" null } { "selector" null }
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
     { "collection" null } { "name" null }
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
     { "collection" null } { "name" null } { "spec" null }
}
{ $description "" } ;

HELP: explain
{ $values
     { "mdb-query" null }
     { "result" null }
}
{ $description "" } ;

HELP: find
{ $values
     { "mdb-query" null }
     { "cursor" null } { "result" null }
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
     { "mdb-cursor" null } { "objects" null }
}
{ $description "" } ;

HELP: hint
{ $values
     { "mdb-query" null } { "index-hint" null }
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
     { "mdb-query" null } { "limit#" null }
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

HELP: master>>
{ $values
     { "mdb" null }
     { "inet" null }
}
{ $description "" } ;

HELP: mdb
{ $values
    
     { "mdb" null }
}
{ $description "" } ;

HELP: mdb-collection
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: mdb-cursor
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: mdb-db
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: mdb-error
{ $values
     { "id" null } { "msg" null }
}
{ $description "" } ;

HELP: mdb-instance
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: mdb-node
{ $values
    
     { "value" null }
}
{ $description "" } ;

HELP: save
{ $values
     { "collection" null } { "assoc" assoc }
}
{ $description "" } ;

HELP: save-unsafe
{ $values
     { "collection" null } { "object" object }
}
{ $description "" } ;

HELP: skip
{ $values
     { "mdb-query" null } { "skip#" null }
     { "mdb-query" null }
}
{ $description "" } ;

HELP: slave>>
{ $values
     { "mdb" null }
     { "inet" null }
}
{ $description "" } ;

HELP: sort
{ $values
     { "mdb-query" null } { "quot" quotation }
     { "mdb-query" null }
}
{ $description "" } ;

HELP: update
{ $values
     { "collection" null } { "selector" null } { "object" object }
}
{ $description "" } ;

HELP: update-unsafe
{ $values
     { "collection" null } { "selector" null } { "object" object }
}
{ $description "" } ;

HELP: validate
{ $values
     { "collection" null }
}
{ $description "" } ;

HELP: with-db
{ $values
     { "mdb" null } { "quot" quotation }
     { "..." null }
}
{ $description "" } ;

ARTICLE: "mongodb.driver" "mongodb.driver"
{ $vocab-link "mongodb.driver" }
;

ABOUT: "mongodb.driver"
