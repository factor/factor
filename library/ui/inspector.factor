USING: gadgets generic hashtables kernel kernel-internals lists
namespaces unparser vectors words ;

DEFER: inspect

: <presentation> ( obj -- gadget )
    dup unparse <label> [
        swap
        [ \ drop , literal, \ inspect , ] make-list
        [ button-up 1 ] set-action
    ] keep
    dup [ drop ] [ button-down 1 ] set-action ;

: label-box ( list -- gadget )
    <line-pile> swap [ <presentation> over add-gadget ] each ;

: alist>sheet ( assoc -- sheet )
    unzip swap
    <default-shelf>
    [ >r label-box r> add-gadget ] keep
    [ >r label-box r> add-gadget ] keep ;

: <titled> ( gadget title -- )
    <line-pile> swap <label> over add-gadget
    [ >r empty-border r> add-gadget ] keep ;

: top-sheet ( obj -- sheet )
    dup class word-name <label> "Class:" <titled>
    swap unparse <label> "Object:" <titled>
    <line-pile> [ add-gadget ] keep [ add-gadget ] keep ;

: object>alist ( obj -- assoc )
    dup class "slots" word-property [
        cdr car [ execute ] keep swons
    ] map-with ;

: slot-sheet ( obj -- sheet )
    object>alist alist>sheet "Slots:" <titled> ;

GENERIC: custom-sheet ( obj -- gadget )

: <inspector> ( obj -- gadget )
    0 default-gap 0 <pile>
    over top-sheet over add-gadget
    over slot-sheet over add-gadget
    swap custom-sheet over add-gadget ;

M: object custom-sheet drop <empty-gadget> ;

M: array custom-sheet ( array -- gadget )
    [ array-capacity [ count ] keep ] keep array>list zip
    alist>sheet
    "Elements:" <titled> ;

M: vector custom-sheet ( array -- gadget )
    dup vector-length count swap vector>list zip alist>sheet
    "Elements:" <titled> ;

M: hashtable custom-sheet ( array -- gadget )
    hash>alist alist>sheet "Entries:" <titled> ;

M: word custom-sheet ( word -- gadget )
    word-props <inspector> empty-border "Properties:" <titled> ;

M: tuple custom-sheet ( tuple -- gadget )
    tuple-delegate [
        <inspector> empty-border "Delegate:" <titled>
    ] [
        <empty-gadget>
    ] ifte* ;

: inspect ( obj -- )
    <inspector> ( <scroller> )
    line-border dup moving-actions world get add-gadget ;

