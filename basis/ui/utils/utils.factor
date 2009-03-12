USING: accessors sequences namespaces ui.render opengl fry ;
IN: ui.utils
SYMBOLS: width height ;
: store-dim ( gadget -- ) dim>> [ first width set ] [ second height set ] bi ;
: with-dim ( gadget quot -- ) '[ _ store-dim @ ] with-scope ;
: with-w/h ( gadget quot -- ) '[ origin get _ with-translation ] with-dim ;