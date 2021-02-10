USING: combinators fry locals kernel math multiline sequences ;

IN: hpack

: hpack-encode ( -- ) ;



! should give the updated dtable, and the list of decoded
! header fields. block is the bytestring for the header block
: hpack-decode ( decode-context block -- updated-context decoded )
    V{ } clone -rot ! a vector for decoded stuff, under the stack inputs
    0 ! index in the block
    ! check that the block is longer than the index
    [ 2keep swap length < ]
    ! call decode-field and add the decode field to the list
    [ decode-field '[ _ [ suffix ] when ] 3dip ]
    while
    ! double check the table size
    ;

! block will be a ...
: decode-field ( decode-context block index -- updated-context block new-index field/f )
    {
        ! the action quote will leave the consumed/new-index,
        ! the field decoded or f, and the block on the stack
        { [ /* 1st bit high */ ] [ /* action quote */ ] } 
        { [ /* 2nd bit high */ ] [ /* action quote */ ] } 
        { [ /* 3rd bit high */ ] [ /* action quote */ ] } 
        [ /* default action quote */ ]
    } cond ;
