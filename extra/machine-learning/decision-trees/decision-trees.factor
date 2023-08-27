! Copyright (C) 2018 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
USING: accessors assocs grouping.extras kernel math
math.functions math.statistics sequences sequences.extras
sorting ;
IN: machine-learning.decision-trees

! Why convert the logarithm to base 2? I don't know.
: entropy2 ( seq -- e )
    normalized-histogram values entropy 2 log / ;

: group-by-sorted ( seq quot: ( elt -- key ) -- groups )
    [ sort-by ] keep group-by ; inline

: subsets-weighted-entropy ( data-target idx -- seq )
    ! Group the data according to the given index.
    '[ first _ swap nth ] group-by-sorted
    ! Then unpack the partitioned groups of targets
    '[ [ second ] map ] assoc-map values
    ! Finally, calculate the weighted entropy for each group
    [ [ entropy2 ] [ length ] bi * ] map-sum ; inline

:: average-gain ( dataset idx -- gain )
    dataset targets>> :> targets
    dataset features>> :> features
    features targets zip :> features-targets
    features-targets idx subsets-weighted-entropy :> weighted

    targets entropy2 weighted features length / - ;

: highest-gain-index ( dataset -- idx )
    dup feature-names>> length <iota> [
        average-gain
    ] with map arg-max ;
