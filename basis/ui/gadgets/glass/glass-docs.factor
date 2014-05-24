USING: help.markup help.syntax kernel math.rectangles
ui.gadgets ;
IN: ui.gadgets.glass

HELP: show-glass
{ $values { "owner" gadget } { "child" gadget } { "visible-rect" rect } }
{ $description "Displays " { $snippet "child" } " in the glass layer of the window containing " { $snippet "owner" } "."
  $nl
  "The child's position is calculated with a heuristic:"
  { $list
    "The child must fit inside the window"
    { "The child must not obscure " { $snippet "visible-rect" } ", which is a rectangle whose origin is relative to " { $snippet "owner" } }
    { "The child must otherwise be as close as possible to the edges of " { $snippet "visible-rect" } }
  }
  "For example, when displaying a menu, " { $snippet "visible-rect" } " is a single point at the mouse location, and when displaying a completion popup, " { $snippet "visible-rect" } " contains the bounds of the text element being completed."
} ;

HELP: hide-glass
{ $values { "child" gadget } }
{ $description "Hides a gadget displayed in a glass layer." } ;

HELP: hide-glass-hook
{ $values { "gadget" gadget } }
{ $description "Called when a gadget displayed in a glass layer is hidden. The gadget can perform cleanup tasks here." } ;

HELP: pass-to-popup
{ $values { "gesture" "a gesture" } { "owner" "the popup's owner" } { "?" boolean } }
{ $description "Resends the gesture to the popup displayed by " { $snippet "owner" } ". The owner must have a " { $slot "popup" } " slot. Outputs " { $link f } " if the gesture was handled, " { $link t } " otherwise." } ;

HELP: show-popup
{ $values { "owner" gadget } { "popup" gadget } { "visible-rect" rect } }
{ $description "Displays " { $snippet "popup" } " in the glass layer of the window containing " { $snippet "owner" } " as a popup."
  $nl
  "This word differs from " { $link show-glass } " in two respects:"
  { $list
    { "The popup is stored in the owner's " { $slot "popup" } " slot; the owner can call " { $link pass-to-popup } " to pass keyboard gestures to the popup" }
    { "Pressing " { $snippet "ESC" } " with the popup visible will hide it" }
  }
} ;

ARTICLE: "ui.gadgets.glass" "Glass layers"
"The " { $vocab-link "ui.gadgets.glass" } " vocabulary implements support for displaying gadgets in the glass layer of a window. The gadget can be positioned arbitrarily within the glass layer, and while it is visible, mouse clicks outside of the glass layer are intercepted to hide the glass layer. Multiple glass layers can be active at a time; they behave as if stacked on top of each other."
$nl
"This feature is used for completion popups and " { $link "ui.gadgets.menus" } " in the " { $link "ui-tools" } "."
$nl
"Displaying a gadget in a glass layer:"
{ $subsections show-glass }
"Hiding a gadget in a glass layer:"
{ $subsections hide-glass }
"Callback generic invoked on the gadget when its glass layer is hidden:"
{ $subsections hide-glass-hook }
"Popup gadgets add support for forwarding keyboard gestures from an owner gadget to the glass layer:"
{ $subsections
    show-popup
    pass-to-popup
} ;

ABOUT: "ui.gadgets.glass"
