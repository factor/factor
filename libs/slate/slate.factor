
USING: kernel namespaces opengl gadgets ;

IN: slate

TUPLE: slate action dim ;

C: slate ( action -- slate )
dup delegate>gadget tuck set-slate-action { 100 100 } over set-slate-dim ;

! M: slate pref-dim* ( slate -- dim ) drop { 100 100 } ;

M: slate pref-dim* ( slate -- dim ) slate-dim ;

! M: slate draw-gadget* ( slate -- ) slate-action call ;

M: slate draw-gadget* ( slate -- )
origin get swap slate-action with-translation ;