USING: accessors fonts generalizations io.styles kernel locals
macros models models.combinators monads sequences
sequences.generalizations ui ui.gadgets ui.gadgets.buttons
ui.gadgets.controls ui.gadgets.editors ui.gadgets.labels
ui.gadgets.layout ui.gadgets.packs wrap.strings ;

IN: ui.gadgets.alerts
:: alert ( quot string -- ) <pile> { 10 10 } >>gap 1 >>align
   string 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font { 200 100 } >>pref-dim add-gadget 
   "okay" [ close-window ] quot append <border-button> add-gadget "" open-window ;

: alert* ( str -- ) [ ] swap alert ;

:: ask-user ( string -- model' )
    [
        string <label>  T{ font { name "sans-serif" } { size 14 } } >>font dup , :> lbl
        <model-field*> ->% 1 :> fldm
        "okay" <model-border-btn> :> btn
        btn -> [ fldm swap updates ]
               [ [ drop lbl close-window ] $> , ] bi
    ] <vbox> { 161 86 } >>pref-dim "" open-window ;

MACRO: ask-buttons ( buttons -- quot ) dup length [
      [ swap
         [ 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font ,
         [ [ <model-border-btn> [ close-window ] >>hook -> ] map ] <hbox> , ] <vbox>
         "" open-window
      ] dip firstn
   ] 2curry ;
