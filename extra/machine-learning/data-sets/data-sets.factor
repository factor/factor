! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs csv io.encodings.utf8 io.files
kernel math.parser sequences splitting ;

IN: machine-learning.data-sets

TUPLE: data-set data target target-names description
feature-names ;

C: <data-set> data-set

<PRIVATE

: load-file ( name -- contents )
    "resource:extra/machine-learning/data-sets/" prepend
    utf8 file-contents ;

: numerify ( table -- data names )
    unclip [ [ [ string>number ] map ] map ] dip ;

: load-table ( name -- data names )
    load-file [ blank? ] trim string-lines
    [ [ blank? ] split-when ] map numerify ;

: load-table-csv ( name -- data names )
    load-file string>csv numerify ;

PRIVATE>

: load-iris ( -- data-set )
    "iris.csv" load-table-csv
    [ [ unclip-last ] { } map>assoc unzip ] [ 2 tail ] bi*
    "iris.rst" load-file
    {
        "sepal length (cm)" "sepal width (cm)"
        "petal length (cm)" "petal width (cm)"
    } <data-set> ;

: load-linnerud ( -- data-set )
    data-set new
        "linnerud_exercise.csv" load-table
        [ >>data ] [ >>feature-names ] bi*
        "linnerud_physiological.csv" load-table
        [ >>target ] [ >>target-names ] bi*
        "linnerud.rst" load-file >>description ;
