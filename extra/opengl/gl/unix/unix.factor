USING: alien.syntax alien.syntax.private kernel
       namespaces parser sequences syntax words ;

IN: opengl.gl.unix

: GL-FUNCTION:
    scan "c-library" get scan
    scan drop "}" parse-tokens drop
    ";" parse-tokens [ "()" subseq? not ] subset
    define-function ; parsing
