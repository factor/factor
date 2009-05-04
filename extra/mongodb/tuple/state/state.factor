USING: classes kernel accessors sequences fry assocs mongodb.tuple.collection
words classes.tuple slots generic ;

IN: mongodb.tuple.state

<PRIVATE

CONSTANT: MDB_TUPLE_INFO       "_mfd_t_info"

PRIVATE>

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

