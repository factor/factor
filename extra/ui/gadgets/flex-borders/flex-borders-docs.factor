! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel
ui.gadgets ui.gadgets.borders ui.gadgets.tracks ;
IN: ui.gadgets.flex-borders

ABOUT: "Flex borders"

ARTICLE: "Flex borders" "Flex borders"
"The idea of the flex border is that it doesn't dictate the size of the contained gadget. If you construct the normal "
{ $link <border> } ", the contained gadget is no longer resized with the parent, because the "
{ $link <border> } " tries to keep it in the middle, which also doesn't propagate the resize requests to the child. The "
{ $link <flex-border> } " is composed of " { $link <track> } "'s, which give full size to the child gadget, but also (optionally) add fixed-size empty gadgets to pad the child from top and bottom and/or from the sides."
{ $subsections <flex-border> } ;

HELP: <flex-border>
{ $values
    { "gadget" "a " { $link gadget } " to add padding to" }
    { "gaps" "a (width, height) " { $link pair } " of padding sizes" }
    { "gadget'" "a new wrapper " { $link gadget } " that contains the "
        { $snippet "gadget" } " and some padding gadgets" }
}
{ $description "Creates a new wrapper gadget that contains "
{ $snippet "gadget" } " and some padding gadgets. The size of the padding is given in "
{ $snippet "gaps" } ". If one of the dimensions in " { $snippet "gaps" }
" is zero or negative, the corresponding padding is not added. If both dimensions are zero or negative, "
{ $link <flex-border> } " does nothing."
$nl
"For example, " { $snippet "gadget { 0 25 } <flex-border>" }
" adds 25 pixels of padding on top and bottom of the " { $snippet "gadget" }
", but not on the sides." } ;
