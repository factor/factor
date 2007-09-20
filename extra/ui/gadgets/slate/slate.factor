
USING: kernel namespaces opengl ui.render ui.gadgets ;

IN: ui.gadgets.slate

TUPLE: slate action dim graft ungraft ;

: <slate> ( action -- slate )
  slate construct-gadget
  tuck set-slate-action
  { 100 100 } over set-slate-dim ;

M: slate pref-dim* ( slate -- dim ) slate-dim ;

M: slate draw-gadget* ( slate -- )
   origin get swap slate-action with-translation ;

M: slate graft* ( slate -- ) slate-graft call ;

M: slate ungraft* ( slate -- ) slate-ungraft call ;