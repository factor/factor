USING: accessors ui ui.gadgets ui.gadgets.labels ui.gadgets.buttons ui.gadgets.packs locals sequences fonts io.styles ;
IN: ui.gadgets.alerts
:: alert ( quot string -- ) <pile> { 10 10 } >>gap 1 >>align string <label> T{ font { name "sans-serif" } { size 18 } } >>font { 200 100 } >>pref-dim add-gadget 
   "okay" [ close-window ] quot append <border-button> add-gadget "" open-window ;