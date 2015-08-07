! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex ui.pens.solid ;
IN: ui.gadgets.theme

CONSTANT: toolbar-background COLOR: grey95
CONSTANT: toolbar-button-pressed-background COLOR: dark-gray

CONSTANT: menu-background COLOR: grey95
CONSTANT: menu-border-color COLOR: grey75

CONSTANT: status-bar-background COLOR: FactorDarkSlateBlue
CONSTANT: status-bar-foreground COLOR: white

CONSTANT: button-text-color COLOR: FactorDarkSlateBlue
CONSTANT: button-clicked-text-color COLOR: white

CONSTANT: line-color COLOR: grey75

CONSTANT: column-title-background COLOR: grey95

CONSTANT: roll-button-rollover-border COLOR: gray50
CONSTANT: roll-button-selected-background COLOR: dark-gray

CONSTANT: source-files-color COLOR: yellow2
CONSTANT: errors-color COLOR: chocolate1
CONSTANT: details-color COLOR: SteelBlue3

CONSTANT: debugger-color COLOR: chocolate1
CONSTANT: completion-color COLOR: magenta

CONSTANT: data-stack-color COLOR: DodgerBlue
CONSTANT: retain-stack-color COLOR: HotPink
CONSTANT: call-stack-color COLOR: GreenYellow

CONSTANT: title-bar-gradient { COLOR: white COLOR: grey90 }

CONSTANT: popup-color COLOR: yellow2

CONSTANT: object-color COLOR: aquamarine2
CONSTANT: contents-color COLOR: orchid2

CONSTANT: help-header-background HEXCOLOR: F4EFD9

CONSTANT: thread-status-stopped-background HEXCOLOR: F4D9D9
CONSTANT: thread-status-suspended-background HEXCOLOR: F4EAD9
CONSTANT: thread-status-running-background HEXCOLOR: EDF4D9

CONSTANT: error-summary-background HEXCOLOR: F4EAD9

CONSTANT: content-background COLOR: white
CONSTANT: text-color COLOR: black
