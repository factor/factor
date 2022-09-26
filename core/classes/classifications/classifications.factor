USING: accessors arrays assocs classes.parser classes.predicate
combinators.short-circuit hash-sets kernel namespaces parser sequences words ;

IN: classes.classifications

! Used for ordering of predicate classes

! predicates are { name predicate-quot } pairs
TUPLE: classification-builder base-class predicates ;
: <classification> ( base-class -- ob )
    V{ } clone classification-builder boa ;

! PREDICATE: classified-predicate-class < predicate-class "disjoint" word-prop >boolean ;

<PRIVATE
SYMBOL: current-classification
PRIVATE>

: exclude-negations ( seq def -- def' )
    [ [ "predicate" word-prop [ not ] compose ] map >array ] dip suffix [ 1&& ] curry ;

! : define-classified-predicate-class ( classifier class superclass definition -- )
!     [ define-predicate-class ] keepdd
!     "classifier" [ swap prefix ] change-word-prop ;

! Create a predicate class that excludes any previous predicate class
: finalize-classification ( classification-builder -- )
    [ predicates>> ] [ base-class>> ] bi
    [let :> ( pred-pairs base )
     pred-pairs keys :> preds
     V{ } clone :> acc
     pred-pairs [ first2 :> ( name def )
             name base acc def exclude-negations
             define-predicate-class
             name preds >hash-set make-disjoint
             name acc push
            ] each
     ! union-name acc >array define-union-class
     ! union-name acc "classifies" set-word-prop
    ] ;

: with-new-classification ( base-class quot -- )
    swap '[ _ <classification> current-classification set ]
    prepose with-scope
    ; inline

: define-classified ( class quot -- )
    2array
    current-classification get predicates>> push ;

DEFER: ELSE:
SYNTAX: AS: scan-new-class parse-definition define-classified ;
: (ELSE:) ( -- ) scan-new-class [ drop t ] define-classified ;

SYNTAX: CLASSIFY scan-class
    [
        \ ELSE: parse-until (ELSE:)
        [ "non-empty-parser-accumulator" throw ] unless-empty
        current-classification get finalize-classification
    ] with-new-classification ;
