
USING: kernel namespaces arrays sequences math x11.xlib 
       mortar slot-accessors x ;

IN: x.font

SYMBOL: <font>

<font> { "dpy" "name" "id" "struct" } accessors define-independent-class

<font> "create" !( name <font> -- font ) [
new-empty swap >>name dpy get >>dpy
dpy get $ptr   over $name   XLoadQueryFont >>struct
dup $struct XFontStruct-fid >>id
] add-class-method

<font> {

"ascent" !( font -- ascent ) [ $struct XFontStruct-ascent ]

"descent" !( font -- ascent ) [ $struct XFontStruct-descent ]

"height" !( font -- ascent ) [ dup <- ascent swap <- descent + ]

"text-width" !( font string -- width ) [ >r $struct r> dup length XTextWidth ]

} add-methods