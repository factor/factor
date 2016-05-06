! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex
ui.gadgets.theme ui.pens.solid ;
IN: ui.gadgets.theme.light

M: light-theme toolbar-background COLOR: grey95 ;
M: light-theme toolbar-button-pressed-background COLOR: dark-gray ;

M: light-theme menu-background COLOR: grey95 ;
M: light-theme menu-border-color COLOR: grey75 ;

M: light-theme status-bar-background COLOR: FactorDarkSlateBlue ;
M: light-theme status-bar-foreground COLOR: white ;

M: light-theme button-text-color COLOR: FactorDarkSlateBlue ;
M: light-theme button-clicked-text-color COLOR: white ;

M: light-theme line-color COLOR: grey75 ;

M: light-theme column-title-background COLOR: grey95 ;

M: light-theme roll-button-rollover-border COLOR: gray50 ;
M: light-theme roll-button-selected-background COLOR: dark-gray ;

M: light-theme source-files-color COLOR: MediumSeaGreen ;
M: light-theme errors-color COLOR: chocolate1 ;
M: light-theme details-color COLOR: SteelBlue3 ;

M: light-theme debugger-color COLOR: chocolate1 ;
M: light-theme completion-color COLOR: magenta ;

M: light-theme data-stack-color COLOR: DodgerBlue ;
M: light-theme retain-stack-color COLOR: HotPink ;
M: light-theme call-stack-color COLOR: GreenYellow ;

M: light-theme title-bar-gradient { COLOR: white COLOR: grey90 } ;

M: light-theme popup-color COLOR: yellow2 ;

M: light-theme object-color COLOR: aquamarine2 ;
M: light-theme contents-color COLOR: orchid2 ;

M: light-theme help-header-background HEXCOLOR: F4EFD9 ;

M: light-theme thread-status-stopped-background HEXCOLOR: F4D9D9 ;
M: light-theme thread-status-suspended-background HEXCOLOR: F4EAD9 ;
M: light-theme thread-status-running-background HEXCOLOR: EDF4D9 ;

M: light-theme thread-status-stopped-foreground HEXCOLOR: F42300 ;
M: light-theme thread-status-suspended-foreground HEXCOLOR: F37B00 ;
M: light-theme thread-status-running-foreground HEXCOLOR: 3FCA00 ;

M: light-theme error-summary-background HEXCOLOR: F4D9D9 ;

M: light-theme content-background COLOR: white ;
M: light-theme text-color COLOR: black ;

M: light-theme link-color COLOR: DodgerBlue4 ;
M: light-theme url-color COLOR: DodgerBlue4 ;
M: light-theme title-color COLOR: gray20 ;
M: light-theme heading-color COLOR: FactorDarkSlateBlue ;
M: light-theme snippet-color COLOR: DarkOrange4 ;
M: light-theme output-color COLOR: DarkOrange4 ;
M: light-theme warning-background-color COLOR: gray90 ;
M: light-theme code-background-color COLOR: FactorLightTan ;

M: light-theme tip-background-color COLOR: lavender ;

M: light-theme prompt-background-color T{ rgba f 1 0.7 0.7 1 } ;

M: light-theme dim-color COLOR: gray35 ;
M: light-theme highlighted-word-color COLOR: DarkSlateGray ;
M: light-theme string-color COLOR: LightSalmon4 ;
M: light-theme stack-effect-color COLOR: FactorDarkGreen ;

M: light-theme vocab-background-color COLOR: FactorLightTan ;
M: light-theme vocab-border-color COLOR: FactorDarkTan ;

M: light-theme field-border-color COLOR: gray ;

M: light-theme selection-color T{ rgba f 0.8 0.8 1.0 1.0 } ;
M: light-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: light-theme focus-border-color COLOR: dark-gray ;

M: light-theme labeled-border-color COLOR: grey85 ;
