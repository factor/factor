USING: classes kernel accessors sequences fry assocs mongodb.tuple.collection
advice words classes.tuple slots ;

IN: mongodb.tuple.state

<PRIVATE

CONSTANT: MDB_TUPLE_INFO       "_mfd_t_info"
CONSTANT: MDB_DIRTY_FLAG       "d?"
CONSTANT: MDB_PERSISTENT_FLAG  "p?"
CONSTANT: MDB_DIRTY_ADVICE     "mdb-dirty-set"

PRIVATE>

: advised-with? ( name word loc -- ? )
   word-prop key? ; inline

: <tuple-info> ( tuple -- tuple-info )
    class V{ } clone tuck  
    [ [ name>> ] dip push ]
    [ [ vocabulary>> ] dip push ] 2bi ; inline

: tuple-info ( assoc -- tuple-info )
    [ MDB_TUPLE_INFO ] dip at ; inline

: set-tuple-info ( tuple assoc -- )
   [ <tuple-info> MDB_TUPLE_INFO ] dip set-at ; inline

: tuple-info? ( assoc -- ? )
   [ MDB_TUPLE_INFO ] dip key? ;

: tuple-meta ( tuple -- assoc )
   dup _mfd>> [ ] [ H{ } clone [ >>_mfd ] keep ] if* nip ; inline

: dirty? ( tuple -- ? )
   [ MDB_DIRTY_FLAG ] dip tuple-meta at ;

: mark-dirty ( tuple -- )
   [ t MDB_DIRTY_FLAG ] dip tuple-meta set-at ;

: persistent? ( tuple -- ? )
   [ MDB_PERSISTENT_FLAG ] dip tuple-meta at ;

: mark-persistent ( tuple -- )
   [ t MDB_PERSISTENT_FLAG ] dip tuple-meta [ set-at ] keep
   [ f MDB_DIRTY_FLAG ] dip set-at ;

: needs-store? ( tuple -- ? )
   [ persistent? not ] [ dirty? ] bi or ;

<PRIVATE

: create-advice ( word -- )
   MDB_DIRTY_ADVICE over after advised-with?
   [ drop ]
   [ [ [ dup mark-dirty ] MDB_DIRTY_ADVICE ] dip advise-after ] if ;

: (annotate-writer) ( class name -- )
   writer-word "methods" word-prop at
   [ create-advice ] when* ;

PRIVATE>

: annotate-writers ( class -- )
   dup all-slots [ name>> ] map
   MDB_ADDON_SLOTS '[ _ memq? not ] filter
   [ (annotate-writer) ] with each ;