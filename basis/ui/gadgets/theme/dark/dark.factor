! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex
ui.gadgets.theme ui.pens.solid ;
IN: ui.gadgets.theme.dark

M: dark-theme toolbar-background COLOR: solarized-base02 ;
M: dark-theme toolbar-button-pressed-background COLOR: solarized-base0 ;

M: dark-theme menu-background COLOR: solarized-base02 ;
M: dark-theme menu-border-color COLOR: solarized-base01 ;

M: dark-theme status-bar-background COLOR: FactorDarkSlateBlue ;
M: dark-theme status-bar-foreground COLOR: white ;

M: dark-theme button-text-color COLOR: solarized-base1 ;
M: dark-theme button-clicked-text-color COLOR: white ;

M: dark-theme line-color COLOR: solarized-base01 ;

M: dark-theme column-title-background COLOR: solarized-base01 ;

M: dark-theme roll-button-rollover-border COLOR: gray50 ;
M: dark-theme roll-button-selected-background COLOR: dark-gray ;

M: dark-theme source-files-color COLOR: solarized-green ;
M: dark-theme errors-color COLOR: solarized-red ;
M: dark-theme details-color COLOR: solarized-blue ;

M: dark-theme debugger-color COLOR: solarized-red ;
M: dark-theme completion-color COLOR: solarized-violet ;

M: dark-theme data-stack-color COLOR: solarized-blue ;
M: dark-theme retain-stack-color COLOR: solarized-magenta ;
M: dark-theme call-stack-color COLOR: solarized-green ;

M: dark-theme title-bar-gradient { COLOR: solarized-base01 COLOR: solarized-base02 } ;

M: dark-theme popup-color COLOR: solarized-yellow ;

M: dark-theme object-color COLOR: solarized-cyan ;
M: dark-theme contents-color COLOR: solarized-magenta ;

M: dark-theme help-header-background HEXCOLOR: 2F4D5B ;

M: dark-theme thread-status-stopped-background HEXCOLOR: 492d33 ;
M: dark-theme thread-status-suspended-background HEXCOLOR: 3c4a24 ;
M: dark-theme thread-status-running-background HEXCOLOR: 2c4f24 ;

M: dark-theme thread-status-stopped-foreground COLOR: solarized-red ;
M: dark-theme thread-status-suspended-foreground COLOR: solarized-yellow ;
M: dark-theme thread-status-running-foreground COLOR: solarized-green ;

M: dark-theme error-summary-background HEXCOLOR: 6E2E32 ;

M: dark-theme content-background COLOR: solarized-base03 ;
M: dark-theme text-color COLOR: grey75 ;

M: dark-theme link-color COLOR: solarized-blue ;
M: dark-theme url-color COLOR: solarized-blue ;
M: dark-theme title-color COLOR: grey75 ;
M: dark-theme heading-color COLOR: grey75 ;
M: dark-theme snippet-color COLOR: solarized-orange ;
M: dark-theme output-color COLOR: solarized-orange ;
M: dark-theme warning-background-color HEXCOLOR: 6E2E32 ;
M: dark-theme code-background-color HEXCOLOR: 2F4D5B ;

M: dark-theme tip-background-color HEXCOLOR: 2F4D5B ;

M: dark-theme prompt-background-color HEXCOLOR: 922f31 ;

M: dark-theme dim-color COLOR: solarized-cyan ;
M: dark-theme highlighted-word-color COLOR: solarized-green ;
M: dark-theme string-color COLOR: solarized-magenta ;
M: dark-theme stack-effect-color COLOR: solarized-orange ;

M: dark-theme vocab-background-color COLOR: solarized-base01 ;
M: dark-theme vocab-border-color COLOR: solarized-base01 ;

M: dark-theme field-border-color COLOR: solarized-base01 ;

M: dark-theme selection-color COLOR: solarized-base01 ;

M: dark-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;

M: dark-theme focus-border-color COLOR: solarized-base01 ;

M: dark-theme labeled-border-color COLOR: grey85 ;
