USING: accessors hashtables images images.viewer io io.styles
kernel math namespaces prettyprint.custom prettyprint.sections
sequences ui.gadgets.panes ;
FROM: images => image ;
IN: images.viewer.prettyprint

TUPLE: image-section < section
    image ;

CONSTANT: approx-pixels-per-cell 8

: <image-section> ( image -- section )
    dup dim>> first approx-pixels-per-cell /i image-section new-section
        over >>image
        swap presented associate >>style ;

M: image-section long-section
    short-section ;
M: image-section short-section
    image>> <image-gadget> output-stream get write-gadget ;

M: image pprint*
    <image-section> add-section ;
