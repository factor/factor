! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: generic kernel namespaces opengl ;

DEFER: set-title ( string world -- )

DEFER: draw-world ! defined in world.factor

DEFER: open-window* ( world title -- )

DEFER: raise-window ( world -- )

DEFER: select-gl-context ( handle -- )

DEFER: flush-gl-context ( handle -- )

DEFER: user-input ( string gadget -- )

: with-gl-context ( handle quot -- )
    swap [ select-gl-context call ] keep
    glFlush flush-gl-context gl-error ; inline

! Two text transfer buffers
TUPLE: clipboard contents ;
C: clipboard "" over set-clipboard-contents ;

GENERIC: paste-clipboard ( gadget clipboard -- )

M: object paste-clipboard
    clipboard-contents dup [ swap user-input ] [ 2drop ] if ;

GENERIC: copy-clipboard ( string gadget clipboard -- )

M: object copy-clipboard nip set-clipboard-contents ;

SYMBOL: clipboard
SYMBOL: selection

<clipboard> clipboard set-global
<clipboard> selection set-global
