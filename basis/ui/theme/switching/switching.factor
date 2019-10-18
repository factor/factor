! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs fonts fry hashtables help.stylesheet help.tips
io.styles kernel listener namespaces prettyprint.stylesheet
sequences ui.theme ui.tools.listener vocabs.prettyprint words ;
IN: ui.theme.switching

<PRIVATE

: update-style ( style color elt -- )
    '[ _ _ rot ?set-at ] change-global ;

: update-stylesheet ( -- )
    ! fonts
    text-color default-font-foreground-color set-global
    content-background default-font-background-color set-global

    ! help.stylesheet
    default-span-style text-color foreground update-style
    link-style link-color foreground update-style
    title-style title-color foreground update-style
    help-path-style help-path-border-color table-border update-style
    heading-style heading-color foreground update-style
    snippet-style snippet-color foreground update-style
    code-style code-background-color page-color update-style
    output-style output-color foreground update-style
    url-style link-color foreground update-style
    warning-style warning-background-color page-color update-style
    warning-style warning-border-color border-color update-style
    deprecated-style deprecated-background-color page-color update-style
    deprecated-style deprecated-border-color border-color update-style
    table-style table-border-color table-border update-style

    ! help.tips
    tip-of-the-day-style tip-background-color page-color update-style

    ! ui.tools.listener
    listener-input-style text-color foreground update-style
    listener-word-style text-color foreground update-style

    ! prettyprint.stylesheet
    { POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: }
    [ "word-style" word-prop [ dim-color foreground  ] dip set-at ] each
    base-word-style text-color foreground update-style
    highlighted-word-style highlighted-word-color foreground update-style
    base-string-style string-color foreground update-style
    base-vocab-style dim-color foreground update-style
    stack-effect-style stack-effect-color foreground update-style

    ! listener
    prompt-style prompt-background-color background update-style
    prompt-style text-color foreground update-style

    ! vocabs.prettyprint
    manifest-style vocab-background-color page-color update-style
    manifest-style vocab-border-color border-color update-style ;

PRIVATE>

: switch-theme ( theme -- )
    theme set-global update-stylesheet ;

: light-mode ( -- ) light-theme switch-theme ;

: dark-mode ( -- ) dark-theme switch-theme ;
