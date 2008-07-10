! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel fry math math.vectors sequences arrays vectors assocs
       hashtables models models.range models.compose combinators
       ui ui.gadgets ui.gadgets.buttons ui.gadgets.frames ui.gadgets.packs
       ui.gadgets.incremental ui.gadgets.viewports ui.gadgets.books ;

IN: ui.gadgets.tabs

TUPLE: tabbed names model toggler content ;

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

: (del-page) ( n name tabbed -- )
    { [ [ remove ] change-names redo-toggler ]
      [ [ names>> length ] [ model>> ] bi
        [ [ = ] keep swap [ 1- ] when
          [ > ] keep swap [ 1- ] when dup ] change-model ]
      [ content>> nth-gadget unparent ]
      [ model>> [ ] change-model ] ! refresh
    } cleave ;

: add-page ( page name tabbed -- )
    [ names>> push ] 2keep
    [ [ model>> swap ]
      [ names>> length 1 - swap ]
      [ toggler>> ] tri add-toggle ]
    [ content>> add-gadget ] bi ;

: del-page ( name tabbed -- )
    [ names>> index ] 2keep (del-page) ;

: <tabbed> ( assoc -- tabbed )
    tabbed new
    [ <pile> 1 >>fill g-> (>>toggler) @left frame,
      [ keys >vector g (>>names) ]
      [ values 0 <model> [ <book> g-> (>>content) @center frame, ] keep ] bi
      g swap >>model redo-toggler ] build-frame ;
