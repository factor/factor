! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex
ui.gadgets.theme ui.pens.solid ;
IN: ui.gadgets.theme.dark

M: dark toolbar-background COLOR: solarized-base02 ;
M: dark toolbar-button-pressed-background COLOR: solarized-base0 ;

M: dark menu-background COLOR: solarized-base02 ;
M: dark menu-border-color COLOR: solarized-base01 ;

M: dark status-bar-background COLOR: FactorDarkSlateBlue ;
M: dark status-bar-foreground COLOR: white ;

M: dark button-text-color COLOR: solarized-base1 ;
M: dark button-clicked-text-color COLOR: white ;

M: dark line-color COLOR: solarized-base01 ;

M: dark column-title-background COLOR: solarized-base01 ;

M: dark roll-button-rollover-border COLOR: gray50 ;
M: dark roll-button-selected-background COLOR: dark-gray ;

M: dark source-files-color COLOR: solarized-green ;
M: dark errors-color COLOR: solarized-red ;
M: dark details-color COLOR: solarized-blue ;

M: dark debugger-color COLOR: solarized-red ;
M: dark completion-color COLOR: solarized-violet ;

M: dark data-stack-color COLOR: solarized-blue ;
M: dark retain-stack-color COLOR: solarized-magenta ;
M: dark call-stack-color COLOR: solarized-green ;

M: dark title-bar-gradient { COLOR: solarized-base01 COLOR: solarized-base02 } ;

M: dark popup-color COLOR: solarized-yellow ;

M: dark object-color COLOR: solarized-cyan ;
M: dark contents-color COLOR: solarized-magenta ;

M: dark help-header-background HEXCOLOR: 2F4D5B ;

M: dark thread-status-stopped-background HEXCOLOR: 492d33 ;
M: dark thread-status-suspended-background HEXCOLOR: 3c4a24 ;
M: dark thread-status-running-background HEXCOLOR: 2c4f24 ;

M: dark thread-status-stopped-foreground COLOR: solarized-red ;
M: dark thread-status-suspended-foreground COLOR: solarized-yellow ;
M: dark thread-status-running-foreground COLOR: solarized-green ;

M: dark error-summary-background HEXCOLOR: 6E2E32 ;

M: dark content-background COLOR: solarized-base03 ;
M: dark text-color COLOR: grey75 ;

M: dark link-color COLOR: solarized-blue ;
M: dark url-color COLOR: solarized-blue ;
M: dark title-color COLOR: grey75 ;
M: dark heading-color COLOR: grey75 ;
M: dark snippet-color COLOR: solarized-orange ;
M: dark output-color COLOR: solarized-orange ;
M: dark warning-background-color HEXCOLOR: 6E2E32 ;
M: dark code-background-color HEXCOLOR: 2F4D5B ;

M: dark tip-background-color HEXCOLOR: 2F4D5B ;

M: dark prompt-background-color HEXCOLOR: 922f31 ;

M: dark dim-color COLOR: solarized-cyan ;
M: dark highlighted-word-color COLOR: solarized-green ;
M: dark string-color COLOR: solarized-magenta ;
M: dark stack-effect-color COLOR: solarized-orange ;

M: dark vocab-background-color COLOR: solarized-base01 ;
M: dark vocab-border-color COLOR: solarized-base01 ;

M: dark field-border-color COLOR: solarized-base01 ;

M: dark selection-color COLOR: solarized-base01 ;

M: dark panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;

M: dark focus-border-color COLOR: solarized-base01 ;

M: dark labeled-border-color COLOR: grey85 ;
