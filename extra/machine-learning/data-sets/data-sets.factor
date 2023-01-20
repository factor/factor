! Copyright (C) 2012 John Benediktsson, Doug Coleman
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs byte-arrays combinators
combinators.short-circuit concurrency.combinators csv grouping
http.client images images.viewer io io.directories
io.encodings.binary io.encodings.utf8 io.files io.launcher
io.pathnames kernel math math.parser namespaces sequences
splitting ui.gadgets.panes ;
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
    load-file [ blank? ] trim split-lines
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

: download-to-directory ( url directory -- )
    dup make-directories
    [
        dup { [ download-name file-exists? ] [ file-stem file-exists? ] } 1|| [
            drop
        ] [
            download
        ] if
    ] with-directory ;

: gzip-decompress-file ( path -- )
    { "gzip" "-d" } swap suffix run-process drop ;

: mnist-data>array ( bytes -- seq )
    16 tail-slice 28 28 * <groups> [
        >byte-array <image>
            swap >>bitmap
            { 28 28 } >>dim
            L >>component-order
            ubyte-components >>component-type
    ] map ;

: mnist-labels>array ( bytes -- seq )
    8 tail-slice >array ;

: image-grid. ( image-seq -- )
    [
        [
            <image-gadget> output-stream get write-gadget
        ] each
        output-stream get stream-nl
    ] each ;

: load-mnist ( -- data-set )
    "resource:datasets" dup make-directories [
        {
            "https://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz"
            "https://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz"
            "https://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz"
            "https://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz"
        }
        [ [ "resource:datasets/" download-to-directory ] parallel-each ]
        [ [ dup file-stem file-exists? [ drop ] [ file-name gzip-decompress-file ] if ] each ]
        [ [ file-stem binary file-contents ] map ] tri
        first4 {
            [ mnist-data>array ]
            [ mnist-labels>array ]
            [ mnist-data>array ]
            [ mnist-labels>array ]
        } spread 4array
    ] with-directory ;
