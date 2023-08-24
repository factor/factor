! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences accessors kernel locals assocs ;
IN: game.models.util

TUPLE: indexed-seq dseq iseq rassoc ;
INSTANCE: indexed-seq sequence

M: indexed-seq length
    iseq>> length ; inline

M: indexed-seq nth
    [ iseq>> nth ] keep dseq>> nth ; inline

M:: indexed-seq set-nth ( elt n seq -- )
    seq dseq>>   :> dseq
    seq iseq>>   :> iseq
    seq rassoc>> :> rassoc
    seq length n = not [ elt n seq immutable ] when
    elt rassoc at
    [
        iseq push
    ]
    [
        dseq length
        [ elt rassoc set-at ]
        [ iseq push ] bi
        elt dseq push
    ] if* ; inline

: <indexed-seq> ( dseq-exemplar iseq-exemplar rassoc-exemplar -- indexed-seq )
    indexed-seq new
    swap clone >>rassoc
    swap clone >>iseq
    swap clone >>dseq ;

M: indexed-seq new-resizable
    [ dseq>> ] [ iseq>> ] [ rassoc>> ] tri <indexed-seq>
    dup -rot
    [ [ dseq>> new-resizable ] keep dseq<< ]
    [ [ iseq>> new-resizable ] keep iseq<< ]
    [ [ rassoc>> clone nip ] keep rassoc<< ]
    2tri ;
