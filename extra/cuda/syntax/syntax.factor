! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser cuda cuda.libraries cuda.utils io.backend
kernel lexer namespaces parser ;
IN: cuda.syntax

SYNTAX: CUDA-LIBRARY:
    scan scan normalize-path
    [ add-cuda-library ]
    [ drop current-cuda-library set-global ] 2bi ;

SYNTAX: CUDA-FUNCTION:
    scan [ create-in current-cuda-library get ] [ ] bi
    ";" scan-c-args drop define-cuda-word ;

: 2<<< ( dim-grid dim-block -- function-launcher )
    0 f function-launcher boa ; inline

: 3<<< ( dim-grid dim-block shared-size -- function-launcher )
    f function-launcher boa ; inline

: 4<<< ( dim-grid dim-block shared-size stream -- function-launcher )
    function-launcher boa ; inline
