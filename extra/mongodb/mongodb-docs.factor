USING: help.markup help.syntax ;
IN: mongodb

ARTICLE: "mongodb" "MongoDB factor integration"
"The " { $vocab-link "mongodb" } " vocabulary provides two different interfaces to the MongoDB document-oriented database"
{ $heading "Low-level driver" }
"The " { $vocab-link "mongodb.driver" } " vocabulary provides a low-level interface to MongoDB."
{ $unchecked-example
  "USING: mongodb.driver ;"
  "\"db\" \"127.0.0.1\" 27017 <mdb>"
  "[ \"mycollection\" [ H{ { \"name\" \"Alfred\" } { \"age\" 57 } } save ] "
  "                 [ \"ageIdx\" [ \"age\" asc ] key-spec <index-spec> ensure-index ]"
  "                 [ H{ { \"age\" H{ { \"$gt\" 50 } } } } <query> find-one ] tri ] with-db "
  "" }
{ $heading "Highlevel tuple integration" }
"The " { $vocab-link "mongodb.tuple" } " vocabulary lets you define persistent tuples that can be stored to and retrieved from a MongoDB database"
{ $unchecked-example
  "USING: mongodb.driver mongodb.tuple fry literals ;"
  "MDBTUPLE: person name age ; "
  "person \"persons\" { } { $[ \"ageIdx\" [ \"age\" asc ] key-spec <tuple-index> ] } define-persistent "
  "\"db\" \"127.0.0.1\" 27017 <mdb>"
  "person new \"Alfred\" >>name 57 >>age"
  "'[ person ensure-table _ save-tuple person new 57 >>age select-tuple ] with-db"
  "" }
;

ABOUT: "mongodb"
