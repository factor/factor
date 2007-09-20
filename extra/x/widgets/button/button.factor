
USING: kernel combinators math x11.xlib
       mortar slot-accessors x.gc x.widgets.label ;

IN: x.widgets.button

SYMBOL: <button>

<button>
  <label>
  { "action-1" "action-2" "action-3" } accessors
define-simple-class

<button> "create" ( <button> -- button ) [
new-empty
<gc> new* >>gc ExposureMask ButtonPressMask bitor >>mask <- init-widget
] add-class-method

<button> "handle-button-press" !( event button -- ) [
{ { [ over XButtonEvent-button Button1 = ] [ nip $action-1 call ] }
  { [ over XButtonEvent-button Button2 = ] [ nip $action-2 call ] }
  { [ over XButtonEvent-button Button3 = ] [ nip $action-3 call ] } }
cond
] add-method