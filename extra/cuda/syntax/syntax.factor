! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser cuda cuda.libraries io.backend
fry kernel lexer namespaces parser ;
IN: cuda.syntax

SYNTAX: CUDA-LIBRARY:
    scan scan-word scan
    '[ _ _ add-cuda-library ]
    [ current-cuda-library set-global ] bi ;

SYNTAX: CUDA-FUNCTION:
    scan [ create-in current-cuda-library get ] keep
    ";" scan-c-args drop define-cuda-function ;

SYNTAX: CUDA-GLOBAL:
    scan [ create-in current-cuda-library get ] keep
    define-cuda-global ;
