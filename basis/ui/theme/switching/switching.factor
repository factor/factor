! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: fry hashtables help.stylesheet help.tips io.styles
kernel listener namespaces ui.theme ui.tools.listener ;
IN: ui.theme.switching

: (update-style) ( style color elt -- )
    '[ _ _ rot ?set-at ] change-global ;

: update-stylesheet ( -- )
    default-span-style text-color foreground (update-style)
    link-style link-color foreground (update-style)
    title-style title-color foreground (update-style)
    heading-style heading-color foreground (update-style)
    snippet-style snippet-color foreground (update-style)
    code-style code-background-color page-color (update-style)
    output-style output-color foreground (update-style)
    url-style url-color foreground (update-style)
    warning-style warning-background-color page-color (update-style)
    deprecated-style warning-background-color page-color (update-style)
    table-style line-color table-border (update-style)
    prompt-style prompt-background-color background (update-style)
    prompt-style text-color foreground (update-style)
    tip-of-the-day-style tip-background-color page-color (update-style)
    listener-input-style text-color foreground (update-style)
    listener-word-style text-color foreground (update-style) ;

: light-mode ( -- ) light-theme theme set-global update-stylesheet ;
: dark-mode ( -- ) dark-theme theme set-global update-stylesheet ;

light-mode
