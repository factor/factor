! Copyright (C) 2005 Chris Double.
!
! A tuple that is persistent has its delegate set as 'persistent'.
! 'persistent' holds the numeric rowid for that tuple in its table.
IN: sqlite.tuple-db
USING: io kernel sequences namespaces slots classes slots.private
assocs math words generic sqlite math.parser ;

! Each slot in a tuple that is storable in the database has
! an instance of a db-field object the gives the name of the 
! database table and slot number in the tuple object of that field.
TUPLE: db-field name bind-name slot type ;

C: <db-field> db-field

! The mapping tuple holds information on how the slots of
! a tuple are mapped to the fields of a sqlite database. 
TUPLE: mapping tuple table fields one-to-one one-to-many   ;

C: <mapping> mapping

: sanitize ( string -- string ) 
    #! Convert a string so it can be used as a table or field name.
    clone
    H{ { CHAR: - CHAR: _ } { CHAR: ? CHAR: p } }
    over substitute ;

: tuple-fields ( class -- seq )
  #! Given a tuple class return a list of the fields
  #! within that tuple. Ignores the delegate field.
  "slots" word-prop 1 tail [
    [ slot-spec-name sanitize dup ":" swap append ] keep
    slot-spec-offset
    "text"
    <db-field>
  ] map ;

: default-mapping ( class -- mapping )  
  #! Given a tuple class, create a default mappings object. It assumes
  #! there are no one-to-one or one-to-many relationships.
  dup [ word-name sanitize ] keep tuple-fields f f <mapping> ;

! The mappings variable holds a hashtable mapping the tuple symbol
! to the mapping object, describing how that tuple is stored
! in the database.
SYMBOL: mappings

: init-mappings ( -- )
  H{ } mappings set-global ;

: get-mappings ( -- hashtable )
  mappings get-global ;

: set-mapping ( mapping -- )
  #! Store a database mapping so that the persistence system 
  #! knows how to store instances of the relevant tuple in the database.
  dup mapping-tuple get-mappings set-at ;

: get-mapping ( class -- mapping )
  #! Return the database mapping for the given tuple class.
  get-mappings at ;

! The 'persistent' tuple will be set to the delegate of any tuple
! instance stored in the database. It contains the database key
! of the row in the database table for the instance or 'f' if it has
! not yet been stored in the database. It also contains the 'mapping'
! object used to translate the fields of the tuple to the database fields.
TUPLE: persistent mapping key ;
: <persistent> ( tuple -- persistent )
  persistent construct-empty
  >r class get-mapping r> 
  [ set-persistent-mapping ] keep ;

: make-persistent ( tuple -- tuple )
  #! Convert the tuple into something that can be stored
  #! into a database by setting its delegate to 'persistent'.
  [ <persistent> ] keep 
  [ set-delegate ] keep ;


: comma-fields ( mapping quot -- string )
  #! Given a mapping, call quot on each field in
  #! the mapping. The contents of quot should call ',' or '%'
  #! to generate output. The output of each quot call
  #! seperated by commas is returned as a string. 'quot' should be
  #! stack effect ( field -- ).
  >r mapping-fields r> [ "" make ] curry map "," join ; inline

GENERIC: create-sql ( mapping -- string )
M: mapping create-sql ( mapping -- string )
  #! Return the SQL used to create a table for storing this type of tuple.
  [
    "create table " % dup mapping-table % 
    " (" % 
    [ dup db-field-name % " " % db-field-type % ] comma-fields %
    ");" %
  ] "" make ;

GENERIC: drop-sql ( mapping -- string )
M: mapping drop-sql ( mapping -- string )
  #! Return the SQL used to drop the table for storing this type of tuple.
  [
    "drop table " % mapping-table % ";" %
  ] "" make ;

GENERIC: insert-sql ( mapping -- string )
M: mapping insert-sql ( mapping -- string )
  #! Return the SQL used to insert a tuple into a table
  [
    "insert into " % dup mapping-table %
    " values(" %
    [ db-field-bind-name % ] comma-fields %
    ");" %
  ] "" make ;

GENERIC: delete-sql ( mapping -- string )
M: mapping delete-sql ( mapping -- string )
  #! Return the SQL used to delete a tuple from a table
  [
    "delete from " % mapping-table %
    " where ROWID=:rowid;" % 
  ] "" make ;

GENERIC: update-sql ( mapping -- string )
M: mapping update-sql ( mapping -- string )
  #! Return the SQL used to update the tuple
  [
    "update " % dup mapping-table %
    " set " %
    [ dup db-field-name % "=" % db-field-bind-name % ] comma-fields %
    " where ROWID=:rowid;" %
  ] "" make ;

GENERIC: select-sql ( tuple mapping -- select )
M: mapping select-sql ( tuple mapping -- select )
  #! Return the SQL used to select a series of tuples from the database. It
  #! will select based on only the filled in fields of the tuple (ie. all non-f).
  [
    "select ROWID,* from " % dup mapping-table %
    mapping-fields [ ! tuple field
      swap over db-field-slot slot ! field value
      [
        [ dup db-field-name % "=" % db-field-bind-name % ] "" make        
      ] [
        drop f
      ] if
    ] curry* map [ ] subset dup length 0 > [
      " where " % 
      " and " join % 
    ] [
      drop
    ] if
    ";" %
  ] "" make ;

: execute-update-sql ( db string -- )
  #! Execute the SQL, which should contain a database update
  #! statement (update, insert, create, etc). Ignore the result.
  sqlite-prepare dup [ drop ] sqlite-each sqlite-finalize ;

: create-tuple-table ( db class -- )
  #! Create the table for the tuple class.
  get-mapping create-sql execute-update-sql ;

: drop-tuple-table ( db class -- )
  #! Create the table for the tuple class.
  get-mapping drop-sql execute-update-sql ;

: bind-for-insert ( statement tuple -- )
  #! Bind the fields in the tuple to the fields in the 
  #! prepared insert statement.
  dup class get-mapping mapping-fields [ ! statement tuple field
    [ db-field-slot slot ] keep ! statement value field
    db-field-bind-name swap ! statement name value
    >r dupd r> sqlite-bind-text-by-name     
  ] curry* each drop ;  

: bind-for-select ( statement tuple -- )
  #! Bind the fields in the tuple to the fields in the 
  #! prepared select statement.
  dup class get-mapping mapping-fields [ ! statement tuple field
    [ db-field-slot slot ] keep ! statement value field
    over [
      db-field-bind-name swap ! statement name value
      >r dupd r> sqlite-bind-text-by-name     
    ] [ 
      2drop 
    ] if
  ] curry* each drop ;  

: bind-for-update ( statement tuple -- )
  #! Bind the fields in the tuple to the fields in the 
  #! prepared update statement.
  2dup bind-for-insert
  >r ":rowid" r> persistent-key sqlite-bind-text-by-name ;

: bind-for-delete ( statement tuple -- )
  #! Bind the fields in the tuple to the fields in the 
  #! prepared delete statement.
  >r ":rowid" r> persistent-key sqlite-bind-text-by-name ;

: (insert-tuple) ( db tuple -- )
  #! Insert this tuple instance into the database. Note that
  #! it inserts only this instance, and not any one-to-one or
  #! one-to-many fields.
  dup class get-mapping insert-sql ! db tuple sql
  swapd sqlite-prepare swap ! statement tuple
  dupd bind-for-insert ! statement
  dup [ drop ] sqlite-each
  sqlite-finalize ;
  
: insert-tuple ( db tuple -- )
  #! Insert this tuple instance into the database and
  #! update the rowid of the insert in the tuple.
  [ (insert-tuple) ] 2keep
  >r sqlite-last-insert-rowid number>string r> make-persistent set-persistent-key ;

: update-tuple ( db tuple -- )
  #! Update this tuple instance in the database. The tuple should have
  #! a delegate of 'persistent' with the key field set.
  dup class get-mapping update-sql ! db tuple sql
  swapd sqlite-prepare swap ! statement tuple
  dupd bind-for-update ! statement
  dup [ drop ] sqlite-each
  sqlite-finalize ;

: save-tuple ( db tuple -- )
  #! Insert or Update the tuple instance depending on whether it
  #! has a persistent delegate.
  dup delegate [ update-tuple ] [ insert-tuple ] if ;

: delete-tuple ( db tuple -- )
  #! Delete this tuple instance from the database. The tuple should have
  #! a delegate of 'persistent' with the key field set.
  dup class get-mapping delete-sql ! db tuple sql
  swapd sqlite-prepare swap ! statement tuple
  dupd bind-for-delete ! statement
  dup [ drop ] sqlite-each
  sqlite-finalize ;

: restore-tuple ( statement tuple -- tuple )
  #! Using 'tuple' as a template, clone it and 
  #! return the clone with fields set to the values from the
  #! database.
  clone dup class get-mapping mapping-fields 1 swap 
  [ ! statement tuple index field )
    over 1+ >r ! statement tuple index field r: index+1
    db-field-slot >r ! statement tuple index r: index+1 slot
    pick swap column-text ! statement tuple value r: index+1 slot
    over r> set-slot r> ! statement tuple index+1
  ] each ! statement tuple index
  drop make-persistent swap 0 column-text swap [ set-persistent-key ] keep ; 

: find-tuples ( db tuple -- seq )
  #! Return a sequence of all tuples in the database that
  #! match the tuple provided as a template. All fields in the
  #! tuple must match the entries in the database, except for 
  #! those set to 'f'. 
  dup class get-mapping dupd select-sql ! db tuple sql
  swapd sqlite-prepare swap ! statement tuple
  2dup bind-for-select ! statement tuple
  [
    over [ ! tuple statement
      over restore-tuple ,
    ] sqlite-each 
  ] { } make nip ! statement tuple accum
  swap sqlite-finalize ;
  
 
get-mappings [ init-mappings ] unless 
