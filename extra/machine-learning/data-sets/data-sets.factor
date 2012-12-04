! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs csv io.encodings.utf8 io.files kernel math.parser
sequences ;

IN: machine-learning.data-sets

TUPLE: data-set data target target-names description
feature-names ;

C: <data-set> data-set

<PRIVATE

: load-file ( name -- contents )
    "resource:extra/machine-learning/data-sets/" prepend
    utf8 file-contents ;

PRIVATE>

: load-iris ( -- data-set )
    "iris.csv" load-file string>csv unclip [
        [
            unclip-last
            [ [ string>number ] map ]
            [ string>number ] bi*
        ] { } map>assoc unzip
    ] [ 2 tail ] bi*
    "iris.rst" load-file
    {
        "sepal length (cm)" "sepal width (cm)"
        "petal length (cm)" "petal width (cm)"
    } <data-set> ;
