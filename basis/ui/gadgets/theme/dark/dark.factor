! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex ui.pens.solid ;
IN: ui.gadgets.theme

CONSTANT: toolbar-background COLOR: solarized-base02
CONSTANT: toolbar-button-pressed-background COLOR: solarized-base0

CONSTANT: menu-background COLOR: solarized-base02
CONSTANT: menu-border-color COLOR: solarized-base01

CONSTANT: status-bar-background COLOR: FactorDarkSlateBlue
CONSTANT: status-bar-foreground COLOR: white

CONSTANT: button-text-color COLOR: solarized-base1
CONSTANT: button-clicked-text-color COLOR: white

CONSTANT: line-color COLOR: solarized-base01

CONSTANT: column-title-background COLOR: solarized-base01

CONSTANT: roll-button-rollover-border COLOR: gray50
CONSTANT: roll-button-selected-background COLOR: dark-gray

CONSTANT: source-files-color COLOR: solarized-green
CONSTANT: errors-color COLOR: solarized-red
CONSTANT: details-color COLOR: solarized-blue

CONSTANT: debugger-color COLOR: solarized-red
CONSTANT: completion-color COLOR: solarized-violet

CONSTANT: data-stack-color COLOR: solarized-blue
CONSTANT: retain-stack-color COLOR: solarized-magenta
CONSTANT: call-stack-color COLOR: solarized-green

CONSTANT: title-bar-gradient { COLOR: solarized-base01 COLOR: solarized-base02 }

CONSTANT: popup-color COLOR: solarized-yellow

CONSTANT: object-color COLOR: solarized-cyan
CONSTANT: contents-color COLOR: solarized-magenta

CONSTANT: help-header-background HEXCOLOR: 2F4D5B

CONSTANT: thread-status-stopped-background HEXCOLOR: 492d33
CONSTANT: thread-status-suspended-background HEXCOLOR: 3c4a24
CONSTANT: thread-status-running-background HEXCOLOR: 2c4f24

CONSTANT: thread-status-stopped-foreground COLOR: solarized-red
CONSTANT: thread-status-suspended-foreground COLOR: solarized-yellow
CONSTANT: thread-status-running-foreground COLOR: solarized-green

CONSTANT: error-summary-background HEXCOLOR: 6E2E32

CONSTANT: content-background COLOR: solarized-base03
CONSTANT: text-color COLOR: grey75

CONSTANT: link-color COLOR: solarized-blue
CONSTANT: url-color COLOR: solarized-blue
CONSTANT: title-color COLOR: grey75
CONSTANT: heading-color COLOR: grey75
CONSTANT: snippet-color COLOR: solarized-orange
CONSTANT: output-color COLOR: solarized-orange
CONSTANT: warning-background-color HEXCOLOR: 6E2E32
CONSTANT: code-background-color HEXCOLOR: 2F4D5B

CONSTANT: tip-background-color HEXCOLOR: 2F4D5B

CONSTANT: prompt-background-color HEXCOLOR: 922f31

CONSTANT: dim-color COLOR: solarized-cyan
CONSTANT: highlighted-word-color COLOR: solarized-green
CONSTANT: string-color COLOR: solarized-magenta
CONSTANT: stack-effect-color COLOR: solarized-orange

CONSTANT: vocab-background-color COLOR: solarized-base01
CONSTANT: vocab-border-color COLOR: solarized-base01

CONSTANT: field-border-color COLOR: solarized-base01

CONSTANT: selection-color COLOR: solarized-base01

CONSTANT: panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 }

CONSTANT: focus-border-color COLOR: solarized-base01

CONSTANT: labeled-border-color COLOR: grey85
