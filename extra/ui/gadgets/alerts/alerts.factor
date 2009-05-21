USING: accessors models kernel ui ui.frp ui.gadgets ui.gadgets.labels
ui.gadgets.editors ui.gadgets.buttons ui.gadgets.packs
locals sequences fonts io.styles ;

IN: ui.gadgets.alerts
:: alert ( quot string -- ) <pile> { 10 10 } >>gap 1 >>align
   string <label> T{ font { name "sans-serif" } { size 18 } } >>font { 200 100 } >>pref-dim add-gadget 
   "okay" [ close-window ] quot append <border-button> add-gadget "" open-window ;

:: ask-user* ( model string -- model' )
   [ [let | lbl  [ string <label>  T{ font { name "sans-serif" } { size 14 } } >>font dup , ]
            fldm [ <frp-field> ->% 1 ]
            btn  [ "okay" <frp-button> model >>model ] |
         btn -> [ fldm swap <updates> ]
                [ [ drop lbl close-window ] $> , ] bi
   ] ] <vbox> { 161 86 } >>pref-dim "" open-window ;

: ask-user ( string -- model ) f <model> swap ask-user* ;