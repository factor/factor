
USING: kernel namespaces opengl ui.render ui.gadgets accessors ;

IN: ui.gadgets.slate

TUPLE: slate < gadget action pdim graft ungraft ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( slate -- slate )
  init-gadget
  [ ]         >>action
  { 200 200 } >>pdim
  [ ]         >>graft
  [ ]         >>ungraft ;

: <slate> ( action -- slate )
  slate new
    init-slate
    swap >>action ;

M: slate pref-dim* ( slate -- dim ) pdim>> ;

M: slate draw-gadget* ( slate -- ) origin get swap action>> with-translation ;

M: slate graft*   ( slate -- ) graft>>   call ;
M: slate ungraft* ( slate -- ) ungraft>> call ;

