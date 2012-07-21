! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.cleave combinators.lib
continuations db db.tuples db.types db.sqlite kernel math
math.parser namespaces parser lexer sets sequences sequences.deep
sequences.lib strings words destructors ;
IN: semantic-db

TUPLE: node id content ;
C: <node> node

node "node"
{
    { "id" "id" +db-assigned-id+ +autoincrement+ }
    { "content" "content" TEXT }
} define-persistent

: delete-node ( node -- ) delete-tuples ;
: create-node ( content -- node ) f swap <node> dup insert-tuple ;
: load-node ( id -- node ) f <node> select-tuple ;

: node-content ( node -- content )
    dup content>> [ nip ] [ select-tuple content>> ] if* ;

: node= ( node node -- ? ) [ id>> ] same? ;

! TODO: get rid of arc id and write our own sql
TUPLE: arc id subject object relation ;

: <arc> ( subject object relation -- arc )
    arc new swap >>relation swap >>object swap >>subject ;

: <id-arc> ( id -- arc )
    arc new swap >>id ;

: delete-arc ( arc -- ) delete-tuples ;

: create-arc ( subject object relation -- )
    [ id>> ] tri@ <arc> insert-tuple ;

: nodes>arc ( subject object relation -- arc )
    [ [ id>> ] [ f ] if* ] tri@ <arc> ;

: select-arcs ( subject object relation -- arcs )
    nodes>arc select-tuples ;

: has-arc? ( subject object relation -- ? )
    select-arcs length 0 > ;

: select-arc-subjects ( subject object relation -- subjects )
    select-arcs [ subject>> f <node> ] map ;

: select-arc-subject ( subject object relation -- subject )
    select-arcs ?first [ subject>> f <node> ] [ f ] if* ;

: select-subjects ( object relation -- subjects )
    f -rot select-arc-subjects ;

: select-subject ( object relation -- subject )
    f -rot select-arc-subject ;

: select-arc-objects ( subject object relation -- objects )
    select-arcs [ object>> f <node> ] map ;

: select-arc-object ( subject object relation -- object )
    select-arcs ?first [ object>> f <node> ] [ f ] if* ;

: select-objects ( subject relation -- objects )
    f swap select-arc-objects ;

: select-object ( subject relation -- object )
    f swap select-arc-object ;

: delete-arcs ( subject object relation -- )
    select-arcs [ delete-arc ] each ;

arc "arc"
{
    { "id" "id" +db-assigned-id+ +autoincrement+ }
    { "relation" "relation" INTEGER +not-null+ }
    { "subject" "subject" INTEGER +not-null+ }
    { "object" "object" INTEGER +not-null+ }
} define-persistent

: create-bootstrap-nodes ( -- )
    "semantic-db" create-node drop
    "has-context" create-node drop ;

: semantic-db-context  T{ node f 1 "semantic-db" } ;
: has-context-relation T{ node f 2 "has-context" } ;

: create-bootstrap-arcs ( -- )
    has-context-relation semantic-db-context has-context-relation create-arc ;

: init-semantic-db ( -- )
    node create-table arc create-table
    create-bootstrap-nodes create-bootstrap-arcs ;

! db utilities
: results ( bindings sql -- array )
    f f <simple-statement> [ do-bound-query ] with-disposal ;

: node-result ( result -- node )
    dup first string>number swap second <node> ;

: ?1node-result ( results -- node )
    ?first [ node-result ] [ f ] if* ;

: node-results ( results -- nodes )
    [ node-result ] map ;

: param ( value key type -- param )
    swapd <sqlite-low-level-binding> ;

: all-node-ids ( -- seq )
    f "select n.id from node n" results [ first string>number ] map ;

: subjects-with-cor ( content object relation -- sql-results )
    [ id>> ] bi@
    [
        ":relation" INTEGER param ,
        ":object" INTEGER param ,
        ":content" TEXT param ,
    ] { } make
    "select n.id, n.content from node n, arc a where n.content = :content and n.id = a.subject and a.relation = :relation and a.object = :object" results ;

: objects-with-csr ( content subject relation -- sql-results )
    [ id>> ] bi@
    [
        ":relation" INTEGER param ,
        ":subject" INTEGER param ,
        ":content" TEXT param ,
    ] { } make
    "select n.id, n.content from node n, arc a where n.content = :content and n.id = a.object and a.relation = :relation and a.subject = :subject" results ;

: (with-relation) ( content relation -- bindings sql )
    id>> [ ":relation" INTEGER param , ":content" TEXT param , ] { } make
    "select distinct n.id, n.content from node n, arc a where n.content = :content and a.relation = :relation" ;

: subjects-with-relation ( content relation -- sql-results )
    (with-relation) " and a.object = n.id" append results ;

: objects-with-relation ( content relation -- sql-results )
    (with-relation) " and a.subject = n.id" append results ;

: (ultimate) ( relation b a -- sql-results )
    [
        "select distinct n.id, n.content from node n, arc a where a.relation = :relation and n.id = a." % % " and n.id not in (select b." % % " from arc b where b.relation = :relation)" %
    ] "" make [ id>> ":relation" INTEGER param 1array ] dip results ;

: ultimate-objects ( relation -- sql-results )
    "subject" "object" (ultimate) ;

: ultimate-subjects ( relation -- sql-results )
    "object" "subject" (ultimate) ;

! contexts:
!  - a node n is a context iff there exists a relation r such that r has context n
: create-context ( context-name -- context ) create-node ;

: get-context ( context-name -- context/f )
    has-context-relation subjects-with-relation ?1node-result ;

: ensure-context ( context-name -- context )
    dup get-context [
        nip
    ] [
        create-context
    ] if* ;

! relations:
!  - have a context in context 'semantic-db'

: create-relation ( relation-name context -- relation )
    [ create-node dup ] dip has-context-relation create-arc ;

: get-relation ( relation-name context -- relation/f )
    has-context-relation subjects-with-cor ?1node-result ;

: ensure-relation ( relation-name context -- relation )
    2dup get-relation [
        2nip
    ] [
        create-relation
    ] if* ;

TUPLE: relation-definition relate id-word unrelate related? subjects objects ;
C: <relation-definition> relation-definition

<PRIVATE

: default-word-name ( relate-word-name word-type -- name>> )
    {
        { "relate" [ ] }
        { "id-word" [ "-relation" append ] }
        { "unrelate" [ "!" swap append ] }
        { "related?" [ "?" append ] }
        { "subjects" [ "-subjects" append ] }
        { "objects" [ "-objects" append ] }
    } case ;

: choose-word-name ( relation-definition given-word-name word-type -- name>> )
    over string? [
        drop nip
    ] [
        nip [ relate>> ] dip default-word-name
    ] if ;

: (define-relation-word) ( id-word name>> definition -- id-word )
    >r create-in over [ execute ] curry r> compose define ;

: define-relation-word ( relation-definition id-word given-word-name word-type definition -- relation-definition id-word )
    >r >r [
        pick swap r> choose-word-name r> (define-relation-word)
    ] [
        r> r> 2drop
    ] if*  ;

: define-relation-words ( relation-definition id-word -- )
    over relate>> "relate" [ create-arc ] define-relation-word
    over unrelate>> "unrelate" [ delete-arcs ] define-relation-word
    over related?>> "related?" [ has-arc? ] define-relation-word
    over subjects>> "subjects" [ select-subjects ] define-relation-word
    over objects>> "objects" [ select-objects ] define-relation-word
    2drop ;

: define-id-word ( relation-definition id-word -- )
    [ relate>> ] dip tuck vocabulary>>
    [ ensure-context ensure-relation ] 2curry define ;

: create-id-word ( relation-definition -- id-word )
    dup id-word>> "id-word" choose-word-name create-in ;

PRIVATE>

: define-relation ( relation-definition -- )
    dup create-id-word 2dup define-id-word define-relation-words ;

: RELATION:
    scan t t t t t <relation-definition> define-relation ; parsing

! hierarchy
TUPLE: node-tree node children ;
C: <node-tree> node-tree

: children ( node has-parent-relation -- children ) select-subjects ;
: parents ( node has-parent-relation -- parents ) select-objects ;

: get-node-tree ( node child-selector -- node-tree )
    2dup call >r [ get-node-tree ] curry r> swap map <node-tree> ;

! : get-node-tree ( node has-parent-relation -- node-tree )
!     2dup children >r [ get-node-tree ] curry r> swap map <node-tree> ;
: get-node-tree-s ( node has-parent-relation -- tree )
    [ select-subjects ] curry get-node-tree ;

: get-node-tree-o ( node has-child-relation -- tree )
    [ select-objects ] curry get-node-tree ;

: (get-node-chain) ( node next-selector seq -- seq )
    pick [
        over push >r [ call ] keep r> (get-node-chain)
    ] [
        2nip
    ] if* ;

: get-node-chain ( node next-selector -- seq )
    V{ } clone (get-node-chain) ;

: get-node-chain-o ( node relation -- seq )
    [ select-object ] curry get-node-chain ;

: get-node-chain-s ( node relation -- seq )
    [ select-subject ] curry get-node-chain ;

: (get-root-nodes) ( node has-parent-relation -- root-nodes/node )
    2dup parents dup empty? [
        2drop
    ] [
        >r nip [ (get-root-nodes) ] curry r> swap map
    ] if ;

: get-root-nodes ( node has-parent-relation -- root-nodes )
    (get-root-nodes) flatten prune ;

