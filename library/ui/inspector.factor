! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors gadgets generic hashtables kernel kernel-internals
lists namespaces strings unparser vectors words ;

: label-box ( list -- gadget )
    <line-pile> swap [ <presentation> over add-gadget ] each ;

: unparse* ( obj -- str ) dup string? [ unparse ] unless ;

: sort-sheet ( assoc -- assoc )
    #! Sort an association list whose keys are arbitrary objects
    [ 2car swap unparse* swap unparse* str-lexi> ] sort ;

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
    object>alist sort-sheet alist>sheet "Slots:" <titled> ;

GENERIC: custom-sheet ( obj -- gadget )

: <inspector> ( obj -- gadget )
    0 default-gap 0 <pile>
    over top-sheet over add-gadget
    over slot-sheet over add-gadget
    swap custom-sheet over add-gadget
    line-border dup moving-actions ;

M: object custom-sheet drop <empty-gadget> ;

M: array custom-sheet ( array -- gadget )
    [ array-capacity [ count ] keep ] keep array>list zip
    alist>sheet
    "Elements:" <titled> ;

M: vector custom-sheet ( array -- gadget )
    dup vector-length count swap vector>list zip alist>sheet
    "Elements:" <titled> ;

M: hashtable custom-sheet ( array -- gadget )
    hash>alist sort-sheet alist>sheet "Entries:" <titled> ;

M: word custom-sheet ( word -- gadget )
    word-props <inspector> empty-border "Properties:" <titled> ;

M: tuple custom-sheet ( tuple -- gadget )
    tuple-delegate [
        <inspector> empty-border "Delegate:" <titled>
    ] [
        <empty-gadget>
    ] ifte* ;

! We ensure that only one inspector is open for each object.
SYMBOL: inspectors

: ensure-ui
    world get dup [ world-running? ] when [
        "Inspector cannot be used if UI not running." throw
    ] unless ;

: inspector ( obj -- gadget )
    #! Return an existing inspector gadget for this object, or
    #! create a new one.
    dup inspectors get assq [
        dup <inspector>
        [ swap inspectors [ acons ] change ] keep
    ] ?unless ;

: inspect ( obj -- )
    #! Show an inspector for the object. The inspector lists
    #! slots and entries in collections.
    ensure-ui global [ inspector world get add-gadget ] bind ;

global [ inspectors off ] bind
