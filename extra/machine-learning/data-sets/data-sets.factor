! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs csv io.encodings.utf8 io.files
kernel math.parser sequences splitting ;

IN: machine-learning.data-sets

TUPLE: data-set
    features targets
    feature-names target-names
    description ;

C: <data-set> data-set

<PRIVATE

: load-file ( name -- contents )
    "resource:extra/machine-learning/data-sets/" prepend
    utf8 file-contents ;

: load-tabular-file ( name -- lines )
    load-file [ blank? ] trim string-lines
    [ [ blank? ] split-when harvest ] map harvest ;

: numerify ( table -- data names )
    unclip [ [ [ string>number ] map ] map ] dip ;

: load-table ( name -- data names )
    load-tabular-file numerify ;

: load-table-csv ( name -- data names )
    load-file string>csv numerify ;

PRIVATE>

: load-monks ( name -- data-set )
    load-tabular-file
    ! Omits the identifiers which are not so interesting.
    [ but-last [ string>number ] map ] map
    [ [ rest ] map ] [ [ first ] map ] bi
    { "a1" "a2" "a3" "a4" "a5" "a6" }
    { "no" "yes" }
    "monks.names" load-file
    <data-set> ;

: load-iris ( -- data-set )
    "iris.csv" load-table-csv
    [ [ unclip-last ] { } map>assoc unzip ] [ 2 tail ] bi*
    {
        "sepal length (cm)" "sepal width (cm)"
        "petal length (cm)" "petal width (cm)"
    } swap
    "iris.rst" load-file
    <data-set> ;

: load-linnerud ( -- data-set )
    data-set new
        "linnerud_exercise.csv" load-table
        [ >>features ] [ >>feature-names ] bi*
        "linnerud_physiological.csv" load-table
        [ >>targets ] [ >>target-names ] bi*
        "linnerud.rst" load-file >>description ;
