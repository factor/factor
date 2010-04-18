! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser cuda kernel lexer parser ;
IN: cuda.syntax

SYNTAX: CUDA-LIBRARY: scan scan add-cuda-library ;

SYNTAX: CUDA-FUNCTION:
    scan [ create-in ] [ ] bi ";" scan-c-args drop define-cuda-word ;

: 3<<< ( dim-block dim-grid shared-size -- function-launcher )
    f function-launcher boa ;

: 4<<< ( dim-block dim-grid shared-size stream -- function-launcher )
    function-launcher boa ;
