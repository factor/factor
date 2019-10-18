USING: accessors sequences namespaces ui.render opengl fry kernel ;
IN: ui.utils
SYMBOLS: width height ;
: store-dim ( gadget -- ) dim>> [ first width set ] [ second height set ] bi ;
: with-dim ( gadget quot -- ) '[ _ store-dim @ ] with-scope ; inline
: with-w/h ( gadget quot -- ) '[ origin get _ with-translation ] with-dim ; inline
