
USING: kernel namespaces opengl ui.render ui.gadgets accessors ;

IN: ui.gadgets.slate

TUPLE: slate < gadget action pdim graft ungraft ;

: <slate> ( action -- slate )
  slate new-gadget
    swap        >>action
    { 100 100 } >>pdim
    [ ]         >>graft
    [ ]         >>ungraft ;

M: slate pref-dim* ( slate -- dim ) pdim>> ;

M: slate draw-gadget* ( slate -- ) origin get swap action>> with-translation ;

M: slate graft*   ( slate -- ) graft>>   call ;
M: slate ungraft* ( slate -- ) ungraft>> call ;

