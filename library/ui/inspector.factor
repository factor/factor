! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors gadgets generic hashtables kernel kernel-internals
lists namespaces sequences strings unparser vectors words ;

: label-box ( list -- gadget )
    0 0 0 <pile> swap [ <presentation> over add-gadget ] each ;

: unparse* ( obj -- str ) dup string? [ unparse ] unless ;

: sort-sheet ( assoc -- assoc )
    #! Sort an association list whose keys are arbitrary objects
    [ 2car swap unparse* swap unparse* string> ] sort ;

: alist>sheet ( assoc -- sheet )
    unzip swap
    <default-shelf>
    [ >r label-box r> add-gadget ] keep
    [ >r label-box r> add-gadget ] keep ;

: <titled> ( gadget title -- gadget )
    0 10 0 <shelf>
    [ >r <label> r> add-gadget ] keep
    [ add-gadget ] keep ;

: top-sheet ( obj -- sheet )
    dup class word-name <label> "Class:" <titled>
    swap unparse <label> "Object:" <titled>
    <line-pile> [ add-gadget ] keep [ add-gadget ] keep ;

: object>alist ( obj -- assoc )
    dup class "slots" word-prop [
        second [ execute ] keep swons
    ] map-with ;

: slot-sheet ( obj -- sheet )
    object>alist sort-sheet alist>sheet "Slots:" <titled> ;

GENERIC: custom-sheet ( obj -- gadget )

: <inspector> ( obj -- gadget )
    0 10 0 <pile>
    over top-sheet over add-gadget
    over slot-sheet over add-gadget
    swap custom-sheet over add-gadget ;

M: object custom-sheet drop <empty-gadget> ;

M: list custom-sheet ( list -- gadget )
    [ length count ] keep zip alist>sheet "Elements:" <titled> ;

M: array custom-sheet ( array -- gadget )
    >list custom-sheet ;

M: vector custom-sheet ( array -- gadget )
    >list custom-sheet ;

M: hashtable custom-sheet ( array -- gadget )
    hash>alist sort-sheet alist>sheet "Entries:" <titled> ;

M: word custom-sheet ( word -- gadget )
    word-props <inspector> empty-border "Properties:" <titled> ;

M: tuple custom-sheet ( tuple -- gadget )
    delegate [
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
    dup inspectors get assq [ ] [
        dup <inspector>
        [ swap inspectors [ acons ] change ] keep
    ] ?ifte ;

: inspector-tile ( obj -- tile )
    inspector <scroller> "Inspector" <tile> ;

: inspect ( obj -- )
    #! Show an inspector for the object. The inspector lists
    #! slots and entries in collections.
    ensure-ui global [
        inspector-tile world get add-gadget
    ] bind ;

global [ inspectors off ] bind
