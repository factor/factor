! Copyright (C) 2021 Kevin Cope.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs colors colors.private io.encodings.utf8
io.files kernel namespaces sequences ui.theme ;
IN: ui.theme.base16

SYMBOL: base16-theme-name
base16-theme-name [ "greenscreen" ] initialize

MEMO: base16colors ( name -- assoc )
    "vocab:ui/theme/base16/base16-" swap ".txt" 3append
    utf8 file-lines parse-colors ;

: named-base16 ( name -- color )
    [ base16-theme-name get base16colors at ] [ no-such-color ] ?unless ;

SINGLETON: base16-theme

M: base16-theme toolbar-background "base00" named-base16 ;
M: base16-theme toolbar-button-pressed-background "base01" named-base16  ;

M: base16-theme menu-background "base00" named-base16 ;
M: base16-theme menu-border-color "base02" named-base16 ;

M: base16-theme status-bar-background "base00" named-base16 ;
M: base16-theme status-bar-foreground "base04" named-base16 ;

M: base16-theme button-text-color "base0C" named-base16 ;
M: base16-theme button-clicked-text-color "base0B" named-base16 ;

M: base16-theme line-color "base02" named-base16 ;
M: base16-theme column-title-background "base00" named-base16 ;

M: base16-theme roll-button-rollover-border "base03" named-base16 ;
M: base16-theme roll-button-selected-background "base02" named-base16 ;

M: base16-theme source-files-color "base0B" named-base16 ;
M: base16-theme errors-color "base08" named-base16 ;
M: base16-theme details-color "base0D" named-base16 ;

M: base16-theme debugger-color "base09" named-base16 ;
M: base16-theme completion-color "base0A" named-base16 ;

M: base16-theme data-stack-color "base0D" named-base16 ;
M: base16-theme retain-stack-color "base0E" named-base16 ;
M: base16-theme call-stack-color "base0B" named-base16 ;

M: base16-theme title-bar-gradient "base01" named-base16 "base01" named-base16 2array ;

M: base16-theme popup-color "base0A" named-base16 ;

M: base16-theme object-color "base0D" named-base16 ;
M: base16-theme contents-color "base0B" named-base16 ;

M: base16-theme help-header-background "base01" named-base16 ;

M: base16-theme thread-status-stopped-background "base0A" named-base16 ;
M: base16-theme thread-status-suspended-background "base0B" named-base16 ;
M: base16-theme thread-status-running-background "base02" named-base16 ;

M: base16-theme thread-status-stopped-foreground "base00" named-base16 ;
M: base16-theme thread-status-suspended-foreground "base00" named-base16 ;
M: base16-theme thread-status-running-foreground "base03" named-base16 ;

M: base16-theme error-summary-background "base01" named-base16 ;

M: base16-theme content-background "base00" named-base16 ;
M: base16-theme text-color "base06" named-base16 ;

M: base16-theme link-color "base0C" named-base16 ;
M: base16-theme title-color "base0B" named-base16 ;
M: base16-theme heading-color "base03" named-base16 ;
M: base16-theme snippet-color "base09" named-base16 ;
M: base16-theme output-color "base09" named-base16 ;
M: base16-theme deprecated-background-color "base01" named-base16 ;
M: base16-theme deprecated-border-color "base01" named-base16 ;
M: base16-theme warning-background-color "base01" named-base16 ;
M: base16-theme warning-border-color "base01" named-base16 ;
M: base16-theme code-background-color "base01" named-base16 ;
M: base16-theme code-border-color "base01" named-base16 ;
M: base16-theme help-path-border-color "base00" named-base16 ;

M: base16-theme tip-background-color "base01" named-base16 ;

M: base16-theme prompt-background-color "base02" named-base16 ;

M: base16-theme dim-color "base03" named-base16 ;
M: base16-theme highlighted-word-color "base04" named-base16 ;
M: base16-theme string-color "base0A" named-base16 ;
M: base16-theme stack-effect-color "base04" named-base16 ;

M: base16-theme field-border-color "base00" named-base16 ;

M: base16-theme editor-caret-color "base06" named-base16 ;
M: base16-theme selection-color "base0D" named-base16 ;
M: base16-theme panel-background-color "base02" named-base16 ;
M: base16-theme focus-border-color "base00" named-base16 ;

M: base16-theme labeled-border-color "base01" named-base16 ;

M: base16-theme table-border-color "base00" named-base16 ;

