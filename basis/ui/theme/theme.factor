! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: colors colors.constants colors.hex namespaces ;
IN: ui.theme

SINGLETON: light-theme

SINGLETON: dark-theme

INITIALIZED-SYMBOL: theme [ light-theme ]

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

M: light-theme toolbar-background color: grey95 ;
M: light-theme toolbar-button-pressed-background color: dark-gray ;

M: light-theme menu-background color: grey95 ;
M: light-theme menu-border-color color: grey75 ;

M: light-theme status-bar-background color: FactorDarkSlateBlue ;
M: light-theme status-bar-foreground color: white ;

M: light-theme button-text-color color: FactorDarkSlateBlue ;
M: light-theme button-clicked-text-color color: white ;

M: light-theme line-color color: grey75 ;

M: light-theme column-title-background color: grey95 ;

M: light-theme roll-button-rollover-border color: gray50 ;
M: light-theme roll-button-selected-background color: dark-gray ;

M: light-theme source-files-color color: MediumSeaGreen ;
M: light-theme errors-color color: chocolate1 ;
M: light-theme details-color color: SteelBlue3 ;

M: light-theme debugger-color color: chocolate1 ;
M: light-theme completion-color color: magenta ;

M: light-theme data-stack-color color: DodgerBlue ;
M: light-theme retain-stack-color color: HotPink ;
M: light-theme call-stack-color color: GreenYellow ;

M: light-theme title-bar-gradient { color: white color: grey90 } ;

M: light-theme popup-color color: yellow2 ;

M: light-theme object-color color: aquamarine2 ;
M: light-theme contents-color color: orchid2 ;

M: light-theme help-header-background hexcolor: F4EFD9 ;

M: light-theme thread-status-stopped-background hexcolor: F4D9D9 ;
M: light-theme thread-status-suspended-background hexcolor: F4EAD9 ;
M: light-theme thread-status-running-background hexcolor: EDF4D9 ;

M: light-theme thread-status-stopped-foreground hexcolor: F42300 ;
M: light-theme thread-status-suspended-foreground hexcolor: F37B00 ;
M: light-theme thread-status-running-foreground hexcolor: 3FCA00 ;

M: light-theme error-summary-background hexcolor: F4D9D9 ;

M: light-theme content-background color: white ;
M: light-theme text-color color: black ;

M: light-theme link-color color: DodgerBlue4 ;
M: light-theme title-color color: gray20 ;
M: light-theme heading-color color: FactorDarkSlateBlue ;
M: light-theme snippet-color color: DarkOrange4 ;
M: light-theme output-color color: DarkOrange4 ;
M: light-theme deprecated-background-color hexcolor: F4EAD9 ;
M: light-theme deprecated-border-color hexcolor: F37B00 ;
M: light-theme warning-background-color hexcolor: F4D9D9 ;
M: light-theme warning-border-color hexcolor: F42300 ;
M: light-theme code-background-color color: FactorLightTan ;
M: light-theme help-path-border-color color: FactorLightTan ;

M: light-theme tip-background-color color: lavender ;

M: light-theme prompt-background-color T{ rgba f 1 0.7 0.7 1 } ;

M: light-theme dim-color color: gray35 ;
M: light-theme highlighted-word-color color: DarkSlateGray ;
M: light-theme string-color color: LightSalmon4 ;
M: light-theme stack-effect-color color: FactorDarkSlateBlue ;

M: light-theme vocab-background-color color: FactorLightTan ;
M: light-theme vocab-border-color color: FactorDarkTan ;

M: light-theme field-border-color color: gray ;

M: light-theme editor-caret-color color: red ;
M: light-theme selection-color T{ rgba f 0.8 0.8 1.0 1.0 } ;
M: light-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: light-theme focus-border-color color: dark-gray ;

M: light-theme labeled-border-color color: grey85 ;

M: light-theme table-border-color color: FactorTan ;

M: dark-theme toolbar-background color: solarized-base02 ;
M: dark-theme toolbar-button-pressed-background color: solarized-base0 ;

M: dark-theme menu-background color: solarized-base02 ;
M: dark-theme menu-border-color color: solarized-base01 ;

M: dark-theme status-bar-background color: FactorDarkSlateBlue ;
M: dark-theme status-bar-foreground color: white ;

M: dark-theme button-text-color color: solarized-base1 ;
M: dark-theme button-clicked-text-color color: white ;

M: dark-theme line-color color: solarized-base01 ;

M: dark-theme column-title-background hexcolor: 2F4D5B ;

M: dark-theme roll-button-rollover-border color: gray50 ;
M: dark-theme roll-button-selected-background color: dark-gray ;

M: dark-theme source-files-color color: solarized-green ;
M: dark-theme errors-color color: solarized-red ;
M: dark-theme details-color color: solarized-blue ;

M: dark-theme debugger-color color: solarized-red ;
M: dark-theme completion-color color: solarized-violet ;

M: dark-theme data-stack-color color: solarized-blue ;
M: dark-theme retain-stack-color color: solarized-magenta ;
M: dark-theme call-stack-color color: solarized-green ;

M: dark-theme title-bar-gradient { color: solarized-base01 color: solarized-base02 } ;

M: dark-theme popup-color color: solarized-yellow ;

M: dark-theme object-color color: solarized-cyan ;
M: dark-theme contents-color color: solarized-magenta ;

M: dark-theme help-header-background hexcolor: 2F4D5B ;

M: dark-theme thread-status-stopped-background hexcolor: 492d33 ;
M: dark-theme thread-status-suspended-background hexcolor: 3c4a24 ;
M: dark-theme thread-status-running-background hexcolor: 2c4f24 ;

M: dark-theme thread-status-stopped-foreground color: solarized-red ;
M: dark-theme thread-status-suspended-foreground color: solarized-yellow ;
M: dark-theme thread-status-running-foreground color: solarized-green ;

M: dark-theme error-summary-background hexcolor: 6E2E32 ;

M: dark-theme content-background color: solarized-base03 ;
M: dark-theme text-color color: grey75 ;

M: dark-theme link-color color: solarized-blue ;
M: dark-theme title-color color: grey75 ;
M: dark-theme heading-color color: grey75 ;
M: dark-theme snippet-color color: solarized-orange ;
M: dark-theme output-color color: solarized-orange ;
M: dark-theme deprecated-background-color hexcolor: 3c4a24 ;
M: dark-theme deprecated-border-color color: solarized-yellow ;
M: dark-theme warning-background-color hexcolor: 492d33 ;
M: dark-theme warning-border-color color: solarized-red ;
M: dark-theme code-background-color hexcolor: 2F4D5B ;
M: dark-theme help-path-border-color hexcolor: 2F4D5B ;

M: dark-theme tip-background-color hexcolor: 2F4D5B ;

M: dark-theme prompt-background-color hexcolor: 922f31 ;

M: dark-theme dim-color color: solarized-cyan ;
M: dark-theme highlighted-word-color color: solarized-green ;
M: dark-theme string-color color: solarized-magenta ;
M: dark-theme stack-effect-color color: solarized-orange ;

M: dark-theme vocab-background-color color: solarized-base01 ;
M: dark-theme vocab-border-color color: solarized-base01 ;

M: dark-theme field-border-color color: solarized-base01 ;

M: dark-theme editor-caret-color color: DeepPink2 ;
M: dark-theme selection-color color: solarized-base01 ;
M: dark-theme panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: dark-theme focus-border-color color: solarized-base01 ;

M: dark-theme labeled-border-color color: solarized-base01 ;

M: dark-theme table-border-color color: solarized-base01 ;
