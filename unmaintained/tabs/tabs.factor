! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel fry math math.vectors sequences arrays vectors assocs
       hashtables models models.range models.product combinators
       ui ui.gadgets ui.gadgets.buttons ui.gadgets.frames ui.gadgets.packs
       ui.gadgets.grids ui.gadgets.viewports ui.gadgets.books locals ;

IN: ui.gadgets.tabs

TUPLE: tabbed < frame names toggler content ;

DEFER: (del-page)

:: add-toggle ( n name model toggler -- )
  <frame>
    n name toggler parent>> '[ drop _ _ _ (del-page) ] "X" swap <bevel-button>
      @right grid-add
    n model name <toggle-button> @center grid-add
  toggler swap add-gadget drop ;

: redo-toggler ( tabbed -- )
     [ names>> ] [ model>> ] [ toggler>> ] tri
     [ clear-gadget ] keep
     [ [ length ] keep ] 2dip
     '[ _ _ add-toggle ] 2each ;

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
    [ [ names>> length 1 - swap ]
      [ model>> ]
      [ toggler>> ] tri add-toggle ]
    [ content>> swap add-gadget drop ]
    [ refresh-book ] tri ;

: del-page ( name tabbed -- )
    [ names>> index ] 2keep (del-page) ;

: new-tabbed ( assoc class -- tabbed )
    new-frame
    0 <model> >>model
    <pile> 1 >>fill >>toggler
    dup toggler>> @left grid-add
    swap
      [ keys >vector >>names ]
      [ values over model>> <book> >>content dup content>> @center grid-add ]
    bi
    dup redo-toggler ;
    
: <tabbed> ( assoc -- tabbed ) tabbed new-tabbed ;
