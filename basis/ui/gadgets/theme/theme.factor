! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: io.pathnames sequences ui.images vocabs namespaces ;
IN: ui.gadgets.theme

: theme-image ( name -- image-name )
    "vocab:ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;

SYMBOL: theme
SINGLETON: light-theme
SINGLETON: dark-theme

light-theme theme set-global

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
HOOK: url-color theme ( -- color )
HOOK: title-color theme ( -- color )
HOOK: heading-color theme ( -- color )
HOOK: snippet-color theme ( -- color )
HOOK: output-color theme ( -- color )
HOOK: warning-background-color theme ( -- color )
HOOK: code-background-color theme ( -- color )

HOOK: tip-background-color theme ( -- color )

HOOK: prompt-background-color theme ( -- color )

HOOK: dim-color theme ( -- color )
HOOK: highlighted-word-color theme ( -- color )
HOOK: string-color theme ( -- color )
HOOK: stack-effect-color theme ( -- color )

HOOK: vocab-background-color theme ( -- color )
HOOK: vocab-border-color theme ( -- color )

HOOK: field-border-color theme ( -- color )

HOOK: selection-color theme ( -- color )
HOOK: panel-background-color theme ( -- color )
HOOK: focus-border-color theme ( -- color )

HOOK: labeled-border-color theme ( -- color )

<< "ui.gadgets.theme.light" require >>
<< "ui.gadgets.theme.dark" require >>
