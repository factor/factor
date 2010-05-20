! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser cuda cuda.libraries io.backend
kernel lexer namespaces parser ;
IN: cuda.syntax

SYNTAX: CUDA-LIBRARY:
    scan scan normalize-path
    [ add-cuda-library ]
    [ drop current-cuda-library set-global ] 2bi ;

SYNTAX: CUDA-FUNCTION:
    scan [ create-in current-cuda-library get ] [ ] bi
    ";" scan-c-args drop define-cuda-word ;

