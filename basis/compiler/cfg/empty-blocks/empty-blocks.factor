! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences namespaces combinators
combinators.short-circuit classes vectors compiler.cfg
compiler.cfg.instructions compiler.cfg.rpo ;
IN: compiler.cfg.empty-blocks

<PRIVATE

: update-predecessor ( bb -- )
    ! We have to replace occurrences of bb with bb's successor
    ! in bb's predecessor's list of successors.
    dup predecessors>> first [
        [
            2dup eq? [ drop successors>> first ] [ nip ] if
        ] with map
    ] change-successors drop ;
 
: update-successor ( bb -- )
    ! We have to replace occurrences of bb with bb's predecessor
    ! in bb's sucessor's list of predecessors.
    dup successors>> first [
        [
            2dup eq? [ drop predecessors>> first ] [ nip ] if
        ] with map
    ] change-predecessors drop ;

SYMBOL: changed?

: delete-basic-block ( bb -- )
    [ update-predecessor ] [ update-successor ] bi
    changed? on ;
 
: delete-basic-block? ( bb -- ? )
    {
        [ instructions>> length 1 = ]
        [ predecessors>> length 1 = ]
        [ successors>> length 1 = ]
        [ instructions>> first ##branch? ]
    } 1&& ;

PRIVATE>

: delete-empty-blocks ( cfg -- cfg' )
    changed? off
    dup [ dup delete-basic-block? [ delete-basic-block ] [ drop ] if ] each-basic-block
    changed? get [ cfg-changed ] when ;