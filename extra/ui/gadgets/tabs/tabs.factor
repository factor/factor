! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel fry math math.vectors sequences arrays vectors assocs
       hashtables models models.range models.compose combinators
       ui ui.gadgets ui.gadgets.buttons ui.gadgets.frames ui.gadgets.packs
       ui.gadgets.grids ui.gadgets.viewports ui.gadgets.books ;

IN: ui.gadgets.tabs

TUPLE: tabbed < frame names toggler content ;

DEFER: (del-page)

: add-toggle ( model n name toggler -- )
    [ [ gadget-parent '[ , , , (del-page) ] "X" swap
       <bevel-button> @right frame, ] 3keep 
      [ swapd <toggle-button> @center frame, ] dip ] make-frame
    swap add-gadget ;

: redo-toggler ( tabbed -- )
     [ names>> ] [ model>> ] [ toggler>> ] tri
     [ clear-gadget ] keep
     [ [ length ] keep ] 2dip
    '[ , _ _ , add-toggle ] 2each ;

: refresh-book ( tabbed -- )
    model>> [ ] change-model ;

: (del-page) ( n name tabbed -- )
    { [ [ remove ] change-names redo-toggler ]
      [ dupd [ names>> length ] [ model>> ] bi
        [ [ = ] keep swap [ 1- ] when
          [ < ] keep swap [ 1- ] when ] change-model ]
      [ content>> nth-gadget unparent ]
      [ refresh-book ]
    } cleave ;

: add-page ( page name tabbed -- )
    [ names>> push ] 2keep
    [ [ model>> swap ]
      [ names>> length 1 - swap ]
      [ toggler>> ] tri add-toggle ]
    [ content>> add-gadget ]
    [ refresh-book ] tri ;

: del-page ( name tabbed -- )
    [ names>> index ] 2keep (del-page) ;

: <tabbed> ( assoc -- tabbed )
    tabbed new-frame
    [ g 0 <model> >>model
      <pile> 1 >>fill [ >>toggler ] keep swap @left grid-add
      [ keys >vector g swap >>names ]
      [ values g model>> <book> [ >>content ] keep swap @center grid-add ] bi
      g redo-toggler g ] with-gadget ;
