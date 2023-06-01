USING: accessors arrays assocs bson.constants combinators
combinators.smart constructors destructors fry hashtables io
io.pools io.sockets kernel linked-assocs locals math
mongodb.cmd mongodb.connection mongodb.msg namespaces parser
prettyprint prettyprint.custom prettyprint.sections sequences
sets splitting strings ;
FROM: ascii => ascii? ;
FROM: math.bitwise => set-bit ;
IN: mongodb.driver

TUPLE: mdb-pool < pool mdb ;

TUPLE: mdb-cursor id query ;

TUPLE: mdb-collection
{ name string }
{ capped boolean }
{ size integer }
{ max integer } ;

CONSTRUCTOR: <mdb-collection> mdb-collection ( name -- collection ) ;

TUPLE: index-spec
{ ns string } { name string } { key hashtable } { unique? boolean initial: f } ;

CONSTRUCTOR: <index-spec> index-spec ( ns name key -- index-spec ) ;

M: mdb-pool make-connection
    mdb>> mdb-open ;

: <mdb-pool> ( mdb -- pool ) [ mdb-pool <pool> ] dip >>mdb ; inline

CONSTANT: PARTIAL? "partial?"

ERROR: mdb-error msg ;

M: mdb-error pprint* ( obj -- )
    msg>> text ;

: >pwd-digest ( user password -- digest )
    "mongo" swap 3array ":" join md5-checksum ;

<PRIVATE

GENERIC: <mdb-cursor> ( id mdb-query-msg/mdb-getmore-msg -- mdb-cursor )

M: mdb-query-msg <mdb-cursor>
    mdb-cursor boa ;

M: mdb-getmore-msg <mdb-cursor>
    query>> mdb-cursor boa ;

: >mdbregexp ( value -- regexp )
   first <mdbregexp> ; inline

GENERIC: update-query ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- )

M: mdb-query-msg update-query
    swap [ start#>> ] [ returned#>> ] bi + >>skip# drop ;

M: mdb-getmore-msg update-query
    query>> update-query ;

: make-cursor ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- mdb-cursor/f )
    over cursor>> 0 >
    [ [ update-query ]
      [ [ cursor>> ] dip <mdb-cursor> ] 2bi
    ] [ 2drop f ] if ;

DEFER: send-query

GENERIC: verify-query-result ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- mdb-result-msg mdb-query-msg/mdb-getmore-msg )

M: mdb-query-msg verify-query-result ;

M: mdb-getmore-msg verify-query-result
    over flags>> ResultFlag_CursorNotFound =
    [ nip query>> [ send-query-plain ] keep ] when ;

: send-query ( mdb-query-msg/mdb-getmore-msg -- mdb-cursor/f seq )
    [ send-query-plain ] keep
    verify-query-result
    [ collection>> >>collection drop ]
    [ return#>> >>requested# ]
    [ make-cursor ] 2tri
    swap objects>> ;


PRIVATE>

SYNTAX: r/
    \ / [ >mdbregexp ] parse-literal ;

: with-db ( mdb quot -- )
    '[ _ mdb-open &dispose _ with-connection ] with-destructors ; inline

: with-mdb ( mdb quot -- )
    [ <mdb-pool> ] dip
    [ mdb-pool swap with-variable ] curry with-disposal ; inline

: with-mdb-pool ( ..a mdb-pool quot -- ..b )
    '[ _ with-connection ] with-pooled-connection ; inline

: with-mdb-connection ( quot -- )
    [ mdb-pool get ] dip with-mdb-pool ; inline

: >id-selector ( assoc -- selector )
    [ MDB_OID_FIELD of ] keep
    H{ } clone [ set-at ] keep ;

: <mdb> ( db host port -- mdb )
    <inet> t [ <mdb-node> ] keep
    H{ } clone [ set-at ] keep <mdb-db>
    [ verify-nodes ] keep ;

GENERIC: create-collection ( name/collection -- )

M: string create-collection
    <mdb-collection> create-collection ;

M: mdb-collection create-collection ( collection -- )
    create-cmd make-cmd over
    {
        [ name>> "create" set-cmd-opt ]
        [ capped>> [ "capped" set-cmd-opt ] when* ]
        [ max>> [ "max" set-cmd-opt ] when* ]
        [ size>> [ "size" set-cmd-opt ] when* ]
    } cleave send-cmd check-ok
    [ drop [ ] [ name>> ] bi mdb-instance collections>> set-at ]
    [ throw ] if ;

: load-collection-list ( -- collection-list )
    namespaces-collection
    H{ } clone <mdb-query-msg> send-query-plain objects>> ;

<PRIVATE

: ensure-valid-collection-name ( collection -- )
    [
        [ ";$." intersect length 0 > ] keep
        '[ _ "contains invalid characters ( . $ ; )" ":" glue throw ] when
    ] [
        [ ascii? ] all? [ "collection names must only contain ascii characters" throw ] unless
    ] bi ; inline

: build-collection-map ( -- assoc )
    H{ } clone load-collection-list
    [ [ "name" ] dip at "." split second <mdb-collection> ] map
    over '[ [ ] [ name>> ] bi _ set-at ] each ;

: ensure-collection-map ( mdb-instance -- assoc )
    dup collections>> dup assoc-empty?
    [ drop build-collection-map [ >>collections drop ] keep ]
    [ nip ] if ;

: (ensure-collection) ( collection mdb-instance -- collection )
    ensure-collection-map dupd key?
    [ ] [
        [ ensure-valid-collection-name ]
        [ create-collection ]
        [ ] tri
    ] if ;

: reserved-namespace? ( name -- ? )
    [ "$cmd" = ] [ "system" head? ] bi or ;

: check-collection ( collection -- fq-collection )
    [let
        mdb-instance :> instance
        instance name>> :> instance-name
        dup mdb-collection? [ name>> ] when
        "." split1 over instance-name =
        [ nip ] [ drop ] if
        [ ] [ reserved-namespace? ] bi
        [ instance (ensure-collection) ] unless
        [ instance-name ] dip "." glue
    ] ;

: fix-query-collection ( mdb-query -- mdb-query )
    [ check-collection ] change-collection ; inline

: get-more ( mdb-cursor -- mdb-cursor seq )
    [ [ query>> dup [ collection>> ] [ return#>> ] bi ]
      [ id>> ] bi <mdb-getmore-msg> swap >>query send-query ]
    [ f f ] if* ;

PRIVATE>

: <query> ( collection assoc -- mdb-query-msg )
    <mdb-query-msg> ; inline

: >slave-ok ( mdb-query-msg -- mdb-query-msg )
    [ 2 set-bit ] change-flags ;

: >await-data ( mdb-query-msg -- mdb-query-msg )
    [ 5 set-bit ] change-flags ;

: >tailable ( mdb-query-msg -- mdb-query-msg )
    [ 1 set-bit ] change-flags ;

: limit ( mdb-query-msg limit# -- mdb-query-msg )
    >>return# ; inline

: skip ( mdb-query-msg skip# -- mdb-query-msg )
    >>skip# ; inline

: asc ( key -- spec ) 1 2array ; inline
: desc ( key -- spec ) -1 2array ; inline

: sort ( mdb-query-msg sort-quot -- mdb-query-msg )
    output>array >hashtable >>orderby ; inline

: filter-fields ( mdb-query-msg filterseq -- mdb-query-msg )
    [ asc ] map >hashtable >>returnfields ; inline

: key-spec ( spec-quot -- spec-assoc )
    output>array >hashtable ; inline

GENERIC#: hint 1 ( mdb-query-msg index-hint -- mdb-query-msg )

M: mdb-query-msg hint
    >>hint ;

GENERIC: find ( selector -- mdb-cursor/f seq )

M: mdb-query-msg find
    fix-query-collection send-query ;

M: mdb-cursor find
    get-more ;

: each-chunk ( selector quot: ( seq -- ) -- )
    swap find
    [ pick call( seq -- ) ] when*
    [ swap each-chunk ] [ drop ] if* ;

: find-all ( selector -- seq )
    [ V{ } clone ] dip
    over '[ _ push-all ] each-chunk >array ;

: explain. ( mdb-query-msg -- )
    t >>explain find nip . ;

: find-one ( mdb-query-msg -- result/f )
    fix-query-collection 1 >>return#
    send-query-plain objects>> ?first ;

: count ( mdb-query-msg -- result )
    [ count-cmd make-cmd ] dip
    [ collection>> "count" set-cmd-opt ]
    [ query>> "query" set-cmd-opt ] bi send-cmd
    [ check-ok nip ] keep '[ "n" _ at >fixnum ] [ f ] if ;

: lasterror ( -- error )
    getlasterror-cmd make-cmd send-cmd
    [ "err" ] dip at ;

GENERIC: validate. ( collection -- )

M: string validate.
    [ validate-cmd make-cmd ] dip
    "validate" set-cmd-opt send-cmd
    [ check-ok nip ] keep
    '[ "result" _ at print ] [  ] if ;

M: mdb-collection validate.
    name>> validate. ;

<PRIVATE

: send-message-check-error ( message -- )
    send-message lasterror [ mdb-error ] when* ;

PRIVATE>

: save ( collection assoc -- )
    [ check-collection ] dip
    <mdb-insert-msg> send-message-check-error ;

: save-unsafe ( collection assoc -- )
    [ check-collection ] dip
    <mdb-insert-msg> send-message ;

: ensure-index ( index-spec -- )
    <linked-hash> [ [ <oid> "_id" ] dip set-at ] keep
    [ { [ [ name>> "name" ] dip set-at ]
        [ [ ns>> index-ns "ns" ] dip set-at ]
        [ [ key>> "key" ] dip set-at ]
        [ swap unique?>>
          [ swap [ "unique" ] dip set-at ] [ drop ] if* ] } 2cleave
    ] keep
    [ index-collection ] dip save ;

: drop-index ( collection name -- )
    [ delete-index-cmd make-cmd ] 2dip
    [ "deleteIndexes" set-cmd-opt ]
    [ "index" set-cmd-opt ] bi* send-cmd drop ;

: <update> ( collection selector object -- mdb-update-msg )
    [ check-collection ] 2dip <mdb-update-msg> ;

: >upsert ( mdb-update-msg -- mdb-update-msg )
    [ 0 set-bit ] change-update-flags ;

: >multi ( mdb-update-msg -- mdb-update-msg )
    [ 1 set-bit ] change-update-flags ;

: update ( mdb-update-msg -- )
    send-message-check-error ;

: update-unsafe ( mdb-update-msg -- )
    send-message ;

: find-and-modify ( collection selector modifier -- mongodb-cmd )
    [ findandmodify-cmd make-cmd ] 3dip
    [ "findandmodify" set-cmd-opt ]
    [ "query" set-cmd-opt ]
    [ "update" set-cmd-opt ] tri* ; inline

: run-cmd ( cmd -- result )
    send-cmd ; inline

: <delete> ( collection selector -- mdb-delete-msg )
    [ check-collection ] dip <mdb-delete-msg> ;

: >single-remove ( mdb-delete-msg -- mdb-delete-msg )
    [ 0 set-bit ] change-delete-flags ;

: delete ( mdb-delete-msg -- )
    send-message-check-error ;

: delete-unsafe ( mdb-delete-msg -- )
    send-message ;

: kill-cursor ( mdb-cursor -- )
    id>> <mdb-killcursors-msg> send-message ;

: load-index-list ( -- index-list )
    index-collection
    H{ } clone <mdb-query-msg> find nip ;

: ensure-collection ( name -- )
    check-collection drop ;

: drop-collection ( name -- )
    [ drop-cmd make-cmd ] dip
    "drop" set-cmd-opt send-cmd drop ;
