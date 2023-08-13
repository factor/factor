USING: accessors hashtables images images.viewer io io.styles
kernel math namespaces prettyprint.custom prettyprint.sections
sequences ui.gadgets.panes ;
IN: images.viewer.prettyprint

TUPLE: image-section < section image ;

CONSTANT: approx-pixels-per-cell 8

: <image-section> ( image -- section )
    dup dim>> first approx-pixels-per-cell /i image-section new-section
        over >>image
        swap presented associate >>style ;

M: image-section short-section
    image>> <image-gadget> output-stream get write-gadget ;

SYMBOL: prettyprint-images?

M: image pprint*
    prettyprint-images? get
    [ <image-section> add-section ]
    [ call-next-method ] if ;
