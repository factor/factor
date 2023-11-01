! Copyright (C) 2016 Nicolas Pénet.
! See https://factorcode.org/license.txt for BSD license.
USING: colors delegate namespaces ;
IN: ui.theme

SYMBOL: theme

HOOK: toolbar-background theme ( -- color )
HOOK: toolbar-button-pressed-background theme ( -- color )

HOOK: menu-background theme ( -- color )
HOOK: menu-border-color theme ( -- color )

HOOK: status-bar-background theme ( -- color )
HOOK: status-bar-foreground theme ( -- color )

HOOK: button-text-color theme ( -- color )
HOOK: button-clicked-text-color theme ( -- color )

HOOK: line-color theme ( -- color )

HOOK: column-title-background theme ( -- color )

HOOK: roll-button-rollover-border theme ( -- color )
HOOK: roll-button-selected-background theme ( -- color )

HOOK: source-files-color theme ( -- color )
HOOK: errors-color theme ( -- color )
HOOK: details-color theme ( -- color )

HOOK: debugger-color theme ( -- color )
HOOK: completion-color theme ( -- color )

HOOK: data-stack-color theme ( -- color )
HOOK: retain-stack-color theme ( -- color )
HOOK: call-stack-color theme ( -- color )

HOOK: title-bar-gradient theme ( -- color )

HOOK: popup-color theme ( -- color )

HOOK: object-color theme ( -- color )
HOOK: contents-color theme ( -- color )

HOOK: help-header-background theme ( -- color )

HOOK: thread-status-stopped-background theme ( -- color )
HOOK: thread-status-suspended-background theme ( -- color )
HOOK: thread-status-running-background theme ( -- color )

HOOK: thread-status-stopped-foreground theme ( -- color )
HOOK: thread-status-suspended-foreground theme ( -- color )
HOOK: thread-status-running-foreground theme ( -- color )

HOOK: error-summary-background theme ( -- color )

HOOK: content-background theme ( -- color )
HOOK: text-color theme ( -- color )

HOOK: link-color theme ( -- color )
HOOK: title-color theme ( -- color )
HOOK: heading-color theme ( -- color )
HOOK: snippet-color theme ( -- color )
HOOK: output-color theme ( -- color )
HOOK: deprecated-background-color theme ( -- color )
HOOK: deprecated-border-color theme ( -- color )
HOOK: warning-background-color theme ( -- color )
HOOK: warning-border-color theme ( -- color )
HOOK: code-background-color theme ( -- color )
HOOK: code-border-color theme ( -- color )
HOOK: help-path-border-color theme ( -- color )

HOOK: tip-background-color theme ( -- color )

HOOK: prompt-background-color theme ( -- color )

HOOK: dim-color theme ( -- color )
HOOK: highlighted-word-color theme ( -- color )
HOOK: string-color theme ( -- color )
HOOK: stack-effect-color theme ( -- color )

HOOK: vocab-background-color theme ( -- color )
HOOK: vocab-border-color theme ( -- color )

HOOK: field-border-color theme ( -- color )

HOOK: editor-caret-color theme ( -- color )
HOOK: selection-color theme ( -- color )
HOOK: panel-background-color theme ( -- color )
HOOK: focus-border-color theme ( -- color )

HOOK: labeled-border-color theme ( -- color )

HOOK: table-border-color theme ( -- color )

! Protocol

PROTOCOL: theme-protocol
toolbar-background toolbar-button-pressed-background
menu-background menu-border-color status-bar-background
status-bar-foreground button-text-color
button-clicked-text-color line-color column-title-background
roll-button-rollover-border roll-button-selected-background
source-files-color errors-color details-color debugger-color
completion-color data-stack-color retain-stack-color
call-stack-color title-bar-gradient popup-color object-color
contents-color help-header-background
thread-status-stopped-background
thread-status-suspended-background
thread-status-running-background
thread-status-stopped-foreground
thread-status-suspended-foreground
thread-status-running-foreground error-summary-background
content-background text-color link-color title-color
heading-color snippet-color output-color
deprecated-background-color deprecated-border-color
warning-background-color warning-border-color
code-background-color code-border-color help-path-border-color
tip-background-color prompt-background-color dim-color
highlighted-word-color string-color stack-effect-color
vocab-background-color vocab-border-color field-border-color
editor-caret-color selection-color panel-background-color
focus-border-color labeled-border-color table-border-color ;

! Light theme

SINGLETON: light-theme
theme [ light-theme ] initialize

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

M: light-theme help-header-background COLOR: #F4EFD9 ;

M: light-theme thread-status-stopped-background COLOR: #F4D9D9 ;
M: light-theme thread-status-suspended-background COLOR: #F4EAD9 ;
M: light-theme thread-status-running-background COLOR: #EDF4D9 ;

M: light-theme thread-status-stopped-foreground COLOR: #F42300 ;
M: light-theme thread-status-suspended-foreground COLOR: #F37B00 ;
M: light-theme thread-status-running-foreground COLOR: #3FCA00 ;

M: light-theme error-summary-background COLOR: #F4D9D9 ;

M: light-theme content-background COLOR: white ;
M: light-theme text-color COLOR: black ;

M: light-theme link-color COLOR: #2A5DB0 ;
M: light-theme title-color COLOR: gray20 ;
M: light-theme heading-color COLOR: FactorDarkSlateBlue ;
M: light-theme snippet-color COLOR: DarkOrange4 ;
M: light-theme output-color COLOR: DarkOrange4 ;
M: light-theme deprecated-background-color COLOR: #F4EAD9 ;
M: light-theme deprecated-border-color COLOR: #F37B00 ;
M: light-theme warning-background-color COLOR: #F4D9D9 ;
M: light-theme warning-border-color COLOR: #F42300 ;
M: light-theme code-background-color COLOR: FactorLightTan ;
M: light-theme code-border-color COLOR: FactorTan ;
M: light-theme help-path-border-color COLOR: grey95 ;

M: light-theme tip-background-color COLOR: lavender ;

M: light-theme prompt-background-color T{ rgba f 1 0.7 0.7 1 } ;

M: light-theme dim-color COLOR: gray35 ;
M: light-theme highlighted-word-color COLOR: DarkSlateGray ;
M: light-theme string-color COLOR: LightSalmon4 ;
M: light-theme stack-effect-color COLOR: FactorDarkSlateBlue ;

M: light-theme field-border-color COLOR: grey75 ;

M: light-theme editor-caret-color COLOR: red ;
M: light-theme selection-color T{ rgba f 0.8 0.8 1.0 1.0 } ;
M: light-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: light-theme focus-border-color COLOR: dark-gray ;

M: light-theme labeled-border-color COLOR: grey85 ;

M: light-theme table-border-color COLOR: FactorTan ;

SINGLETON: dark-theme

M: dark-theme toolbar-background COLOR: #202124 ;
M: dark-theme toolbar-button-pressed-background COLOR: solarized-base0 ;

M: dark-theme menu-background COLOR: #202124 ;
M: dark-theme menu-border-color COLOR: solarized-base01 ;

M: dark-theme status-bar-background COLOR: FactorDarkSlateBlue ;
M: dark-theme status-bar-foreground COLOR: white ;

M: dark-theme button-text-color COLOR: solarized-base1 ;
M: dark-theme button-clicked-text-color COLOR: white ;

M: dark-theme line-color COLOR: solarized-base01 ;

M: dark-theme column-title-background COLOR: #2F4D5B ;

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

M: dark-theme help-header-background COLOR: #2F4D5B ;

M: dark-theme thread-status-stopped-background COLOR: #492d33 ;
M: dark-theme thread-status-suspended-background COLOR: #3c4a24 ;
M: dark-theme thread-status-running-background COLOR: #2c4f24 ;

M: dark-theme thread-status-stopped-foreground COLOR: solarized-red ;
M: dark-theme thread-status-suspended-foreground COLOR: solarized-yellow ;
M: dark-theme thread-status-running-foreground COLOR: solarized-green ;

M: dark-theme error-summary-background COLOR: #6E2E32 ;

M: dark-theme content-background COLOR: #202124 ;
M: dark-theme text-color COLOR: #bdc1c6 ;

M: dark-theme link-color COLOR: #8ab4f8 ;
M: dark-theme title-color COLOR: grey75 ;
M: dark-theme heading-color COLOR: grey75 ;
M: dark-theme snippet-color COLOR: solarized-orange ;
M: dark-theme output-color COLOR: solarized-orange ;
M: dark-theme deprecated-background-color COLOR: #3c4a24 ;
M: dark-theme deprecated-border-color COLOR: solarized-yellow ;
M: dark-theme warning-background-color COLOR: #492d33 ;
M: dark-theme warning-border-color COLOR: solarized-red ;
M: dark-theme code-background-color COLOR: #2F4D5B ;
M: dark-theme code-border-color COLOR: #666666 ;
M: dark-theme help-path-border-color COLOR: solarized-base02 ;

M: dark-theme tip-background-color COLOR: #2F4D5B ;

M: dark-theme prompt-background-color COLOR: #922f31 ;

M: dark-theme dim-color COLOR: solarized-cyan ;
M: dark-theme highlighted-word-color COLOR: solarized-green ;
M: dark-theme string-color COLOR: solarized-magenta ;
M: dark-theme stack-effect-color COLOR: solarized-orange ;

M: dark-theme field-border-color COLOR: solarized-base01 ;

M: dark-theme editor-caret-color COLOR: DeepPink2 ;
M: dark-theme selection-color COLOR: solarized-base01 ;
M: dark-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: dark-theme focus-border-color COLOR: solarized-base01 ;

M: dark-theme labeled-border-color COLOR: solarized-base01 ;

M: dark-theme table-border-color COLOR: solarized-base01 ;
