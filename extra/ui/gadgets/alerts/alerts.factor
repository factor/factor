USING: accessors models macros generalizations kernel ui
ui.frp.gadgets ui.frp.signals ui.frp.layout ui.gadgets
ui.gadgets.labels ui.gadgets.editors ui.gadgets.buttons
ui.gadgets.packs locals sequences fonts io.styles wrap.strings ;

IN: ui.gadgets.alerts
:: alert ( quot string -- ) <pile> { 10 10 } >>gap 1 >>align
   string 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font { 200 100 } >>pref-dim add-gadget 
   "okay" [ close-window ] quot append <border-button> add-gadget "" open-window ;

: alert* ( str -- ) [ ] swap alert ;

:: ask-user* ( model string -- model' )
   [ [let | lbl  [ string <label>  T{ font { name "sans-serif" } { size 14 } } >>font dup , ]
            fldm [ <frp-field> ->% 1 ]
            btn  [ "okay" <frp-bevel-button> model >>model ] |
         btn -> [ fldm swap <updates> ]
                [ [ drop lbl close-window ] $> , ] bi
   ] ] <vbox> { 161 86 } >>pref-dim "" open-window ;

: ask-user ( string -- model ) f <model> swap ask-user* ;

MACRO: ask-buttons ( buttons -- quot ) dup length [
      [ swap
         [ 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font ,
         [ [ <frp-bevel-button> [ close-window ] >>hook -> ] map ] <hbox> , ] <vbox>
         { 200 110 } >>pref-dim "" open-window
      ] dip firstn
   ] 2curry ;