This is the attempt to implement a driver for MongoDB
(http://www.mongodb.org) in Factor (http://www.factorcode.org).

Usage example (for a quick overview):

USE: mongodb.driver

! 1. initialize mdb
! database host port <mdb>
"db" "127.0.0.1" 27017 <mdb>

! 2. create an index
! <mdb> [ collection name spec ensure-index ] with-db
dup [ "test" "idIdx" H{ { "_id" 1 } } ensure-index ] with-db

! 3. insert an object
! <mdb> [ collection object save ] with-db
dup [ "test" H{ { "_id" "12345" } { "name" "myobject" } } save ] with-db

! 4. find the object
! <mdb> [ collection example <query> ..options.. find ] with-db
dup [ "test" H{ { "_id" "12345" } } <query> find ] with-db

! a find with options would look like this

dup [ "test" H{ { "name" "myobject" } } <query> 10 limit 
      [ "_id" asc "name" desc ] sort find ] with-db
