USING: continuations namespaces tools.deploy.shaker ;
IN: debugger

: error. ( error -- ) original-error get die-with2 ;

: print-error ( error -- ) error. ;
