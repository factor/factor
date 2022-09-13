USING: accessors math.vectors ;
IN: ui.images

: image-dim ( image-name -- dim )
    cached-image dim>> 1/2 v*n ;
