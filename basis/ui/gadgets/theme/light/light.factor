! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex
ui.gadgets.theme ui.pens.solid ;
IN: ui.gadgets.theme.light

M: light toolbar-background COLOR: grey95 ;
M: light toolbar-button-pressed-background COLOR: dark-gray ;

M: light menu-background COLOR: grey95 ;
M: light menu-border-color COLOR: grey75 ;

M: light status-bar-background COLOR: FactorDarkSlateBlue ;
M: light status-bar-foreground COLOR: white ;

M: light button-text-color COLOR: FactorDarkSlateBlue ;
M: light button-clicked-text-color COLOR: white ;

M: light line-color COLOR: grey75 ;

M: light column-title-background COLOR: grey95 ;

M: light roll-button-rollover-border COLOR: gray50 ;
M: light roll-button-selected-background COLOR: dark-gray ;

M: light source-files-color COLOR: MediumSeaGreen ;
M: light errors-color COLOR: chocolate1 ;
M: light details-color COLOR: SteelBlue3 ;

M: light debugger-color COLOR: chocolate1 ;
M: light completion-color COLOR: magenta ;

M: light data-stack-color COLOR: DodgerBlue ;
M: light retain-stack-color COLOR: HotPink ;
M: light call-stack-color COLOR: GreenYellow ;

M: light title-bar-gradient { COLOR: white COLOR: grey90 } ;

M: light popup-color COLOR: yellow2 ;

M: light object-color COLOR: aquamarine2 ;
M: light contents-color COLOR: orchid2 ;

M: light help-header-background HEXCOLOR: F4EFD9 ;

M: light thread-status-stopped-background HEXCOLOR: F4D9D9 ;
M: light thread-status-suspended-background HEXCOLOR: F4EAD9 ;
M: light thread-status-running-background HEXCOLOR: EDF4D9 ;

M: light thread-status-stopped-foreground HEXCOLOR: F42300 ;
M: light thread-status-suspended-foreground HEXCOLOR: F37B00 ;
M: light thread-status-running-foreground HEXCOLOR: 3FCA00 ;

M: light error-summary-background HEXCOLOR: F4D9D9 ;

M: light content-background COLOR: white ;
M: light text-color COLOR: black ;

M: light link-color COLOR: DodgerBlue4 ;
M: light url-color COLOR: DodgerBlue4 ;
M: light title-color COLOR: gray20 ;
M: light heading-color COLOR: FactorDarkSlateBlue ;
M: light snippet-color COLOR: DarkOrange4 ;
M: light output-color COLOR: DarkOrange4 ;
M: light warning-background-color COLOR: gray90 ;
M: light code-background-color COLOR: FactorLightTan ;

M: light tip-background-color COLOR: lavender ;

M: light prompt-background-color T{ rgba f 1 0.7 0.7 1 } ;

M: light dim-color COLOR: gray35 ;
M: light highlighted-word-color COLOR: DarkSlateGray ;
M: light string-color COLOR: LightSalmon4 ;
M: light stack-effect-color COLOR: FactorDarkGreen ;

M: light vocab-background-color COLOR: FactorLightTan ;
M: light vocab-border-color COLOR: FactorDarkTan ;

M: light field-border-color COLOR: gray ;

M: light selection-color T{ rgba f 0.8 0.8 1.0 1.0 } ;

M: light panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;

M: light focus-border-color COLOR: dark-gray ;

M: light labeled-border-color COLOR: grey85 ;
