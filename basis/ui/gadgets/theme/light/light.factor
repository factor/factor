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

CONSTANT: source-files-color COLOR: MediumSeaGreen
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

CONSTANT: thread-status-stopped-foreground HEXCOLOR: F42300
CONSTANT: thread-status-suspended-foreground HEXCOLOR: F37B00
CONSTANT: thread-status-running-foreground HEXCOLOR: 3FCA00

CONSTANT: error-summary-background HEXCOLOR: F4D9D9

CONSTANT: content-background COLOR: white
CONSTANT: text-color COLOR: black

CONSTANT: link-color COLOR: DodgerBlue4
CONSTANT: url-color COLOR: DodgerBlue4
CONSTANT: title-color COLOR: gray20
CONSTANT: heading-color COLOR: FactorDarkSlateBlue
CONSTANT: snippet-color COLOR: DarkOrange4
CONSTANT: output-color COLOR: DarkOrange4
CONSTANT: warning-background-color COLOR: gray90
CONSTANT: code-background-color COLOR: FactorLightTan

CONSTANT: tip-background-color COLOR: lavender

CONSTANT: prompt-background-color T{ rgba f 1 0.7 0.7 1 }

CONSTANT: dim-color COLOR: gray35
CONSTANT: highlighted-word-color COLOR: DarkSlateGray
CONSTANT: string-color COLOR: LightSalmon4
CONSTANT: stack-effect-color COLOR: FactorDarkGreen

CONSTANT: vocab-background-color COLOR: FactorLightTan
CONSTANT: vocab-border-color COLOR: FactorDarkTan

CONSTANT: field-border-color COLOR: gray

CONSTANT: selection-color T{ rgba f 0.8 0.8 1.0 1.0 }

CONSTANT: panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 }

CONSTANT: focus-border-color COLOR: dark-gray

CONSTANT: labeled-border-color COLOR: grey85
