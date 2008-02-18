! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math namespaces new-slots sequences sqlite ;
IN: semantic-db.db

! sqlite utils
: prepare ( string -- statement )
    db get swap sqlite-prepare ;

: binding ( statement key val -- statement )
    >r dup integer? [ 1+ ] when dupd r> sqlite-bind-by-name-or-index ;

GENERIC# bindings 1 ( bindings statement -- statement )

M: assoc bindings
    swap [ binding ] assoc-each ;

M: sequence bindings
    swap dup length swap [ binding ] 2each ;

: prepare-with-bindings ( bindings string -- statement )
    prepare bindings ;

: select-with-bindings ( bindings string quot -- results )
    >r prepare-with-bindings dup r> sqlite-map swap sqlite-finalize ;

: ignore-and-finalize ( statement -- )
    dup [ drop ] sqlite-each sqlite-finalize ;

: sql-update ( string -- )
    prepare ignore-and-finalize ;

: update-with-bindings ( bindings string -- )
    prepare-with-bindings ignore-and-finalize ;

: 1result ( array -- result )
    #! return the first (and hopefully only) element of the array, or f
    dup length 0 > [ first ] [ drop f ] if ;

: (collect-int-columns) ( statement n -- )
    [ dupd column-int , ] each drop ;

: collect-int-columns ( statement n -- columns )
    [ (collect-int-columns) ] { } make ;

! queries
TUPLE: field name table retriever ;
C: <field> field

TUPLE: query fields tables conditions args statement results ;

: call-field-retrievers ( query 

: <query> ( -- query )
    V{ } clone V{ } clone V{ } clone H{ } clone f f
    query construct-boa ;

: invalidate-query ( query -- query )
    f >>results ;

: add-field ( field query -- query )
    dup invalidate-query fields>> push ;

: add-table ( table query -- query )
    dup invalidate-query tables>> push ;

: add-condition ( condition query -- query )
    tuck invalidate-query conditions>> push ;

: add-arg ( arg key query -- query )
    [ invalidate-query args>> set-at ] keep ;

<PRIVATE

: field-sql ( field -- sql )
    [ dup table>> % CHAR: . , name>> % ] "" make ;

: fields-sql ( query -- sql )
    fields>> dup length [
        [ field-sql ] map ", " join
    ] [
        drop "*"
    ] if ;

: tables-sql ( query -- sql )
    tables>> ", " join ;

: conditions-sql ( query -- sql )
    conditions>> dup length [
        " and " join "where " swap append
    ] [
        drop ""
    ] if ;

: query-sql ( query -- sql )
    [
        "select" , dup fields-sql , dup "from" , tables-sql , conditions-sql ,
    ] { } make " " join ;

: prepare-query ( query -- query )
    dup query-sql prepare >>statement ;

: bind-query ( query -- query )
    dup args>> over statement>> bindings >>statement ;

: (retrieve) ( statement query -- result )
    fields>> swap [ retriever>> call ] curry each ;

: retrieve ( query -- query )
    dup statement>> over [ (retrieve) ] curry sqlite-map
    swap >>results ;
   ! dup query-statement over query-retriever sqlite-map swap >>results ;

: finalize-query ( query -- query )
    statement>> dup sqlite-finalize f swap >>statement ;

PRIVATE>
    
: run-query ( query -- )
    dup prepare-query dup bind-query dup retrieve finalize-query ;

: get-results ( query -- results )
    dup results>> [ nip ] [ dup run-query results>> ] if* ;

! nodes and arcs

! maybe merge nodes and arcs table, so arcs can be nodes too:
! create table nodes (id integer primary key autoincrement, value none, type integer, subject integer, object integer)
! nodes:
!   value: node content
!   type: nid of node type
!   subject: null
!   object: null
!
! arcs:
!   value: ordinality, or null
!   type: nid of relation
!   subject: nid of arc subject
!   object: nid of arc object
!
! An alternative layout:
!
! nodes:
!   id
!   type
!
! content:
!   id
!   content
!
! arcs:
!   id
!   relation
!   subject
!   object
!   ordinal
!
! A third alternative. In this, all arcs have an entry in the nodes table, but
! their content is null. No node that isn't an arc can have null content. If an
! arc needs an ordinal, then it can be created as another arc.
!
! nodes:
!   id
!   content
!
! arcs:
!   id
!   relation
!   subject
!   object

: create-node-table ( -- )
    "create table nodes (id integer primary key autoincrement, content none);" sql-update ;

: create-arc-table ( -- )
    "create table arcs (id integer, relation integer, subject integer, object integer);" sql-update ;

: create-node ( content -- id )
    #! if content is f then it is inserted as NULL
    [ 1array ] [ drop { } clone ] if*
    "insert into nodes (content) values (?);"
    update-with-bindings db get sqlite-last-insert-rowid ;

: create-bootstrap-nodes ( -- )
    { "context" "relation" "is of type" "semantic-db" "is in context" }
    [ create-node drop ] each ;

: context-type 1 ; inline
: relation-type 2 ; inline
: has-type-relation 3 ; inline
: semantic-db-context 4 ; inline
: has-context-relation 5 ; inline

: create-arc ( relation subject object -- id )
    f create-node -roll 4array
    "insert into arcs (id, relation, subject, object) values (?, ?, ?, ?);"
    update-with-bindings ;

: create-bootstrap-arcs ( -- )
    has-type-relation has-type-relation relation-type create-arc drop
    has-type-relation semantic-db-context context-type create-arc drop
    has-context-relation has-type-relation semantic-db-context create-arc drop
    has-type-relation has-context-relation relation-type create-arc drop
    has-context-relation has-context-relation semantic-db-context create-arc drop ;

: init-semantic-db ( -- )
    create-node-table create-arc-table create-bootstrap-nodes create-bootstrap-arcs ;

: node-content ( id -- content )
    1array "select content from nodes where id = ?" [ 0 column-text ] select-with-bindings 1result ;

: node-arcs ( node-id -- arcs )
    1array "select id, relation, subject, object from arcs where subject = ?1 or object = ?1;"
    [ 4 collect-int-columns ] select-with-bindings ;

: node-subject-arcs ( node-id -- arcs )
    1array "select object, relation from arcs where subject = ?;"
    [ 2 collect-int-columns ] select-with-bindings ;

: node-object-arcs ( node-id -- arcs )
    1array "select subject, relation from arcs where object = ?;"
    [ 2 collect-int-columns ] select-with-bindings ;

: relation-subject-objects ( relation subject -- objects )
    2array "select object from arcs where relation = ? and subject = ?;"
    [ 0 column-int ] select-with-bindings ;

: relation-object-subjects ( relation object -- subjects )
    2array "select subject from arcs where relation = ? and object = ?;"
    [ 0 column-int ] select-with-bindings ;

: subject-object-relations ( subject object -- relations )
    2array "select relation from arcs where subject = ? and object = ?"
    [ 0 column-int ] select-with-bindings ;

: type-and-name-node ( type name -- node )
    has-type-relation 3array
    "select n.id from arcs a, nodes n where a.subject = n.id and a.object = ? and n.name = ? and a.relation = ?"
    [ 0 column-int ] select-with-bindings 1result ;

: create-node-of-type ( type name -- node )
    create-node [ has-type-relation -rot create-arc drop ] keep ;

: ensure-node-of-type ( type name -- node )
    2dup type-and-name-node [ 2nip ] [ create-node-of-type ] if* ;

: type-and-name-in-context-node ( context type name -- node )
    <query>
    "id" "n" [ 0 column-int ] add-field
    "nodes n" add-table
    "n.name = :name" add-condition
    ":name" add-arg
    "arcs a" add-table
    "a.relation = :has_type" add-condition
    has-type-relation ":has_type" add-arg
    "a.subject = n.id" add-condition
    "a.object = :type" add-condition
    ":type" add-arg
    "arcs b" add-table
    "b.subject = a.relation" add-condition
    "b.relation = :has_context" add-condition
    has-context-relation ":has_context" add-arg
    "b.object = :context" add-condition
    ":context" add-arg
    get-results 1result ;


! ideas for an api:
! this would work something like jquery, where arcs can be selected according
! to parameters, and the contents of nodes and arcs are retrieved on demand, or
! at the program's convenience. It may be better to do this as a query language.
! TUPLE: node id content ;
! : node-text ( node -- text )
!     dup node-content [
!         nip
!     ] [
!         node-id ! now get content from database, save it in node-content, and return it
!     ] if* ;
! TUPLE: arc id relation subject object ;
! 
! TUPLE: arcs ids relation subject object ;
