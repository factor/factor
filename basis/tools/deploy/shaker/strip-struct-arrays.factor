USING: kernel stack-checker.transforms struct-arrays.private ;
IN: struct-arrays

: struct-element-constructor ( c-type -- word )
    "Struct array usages must be compiled" throw ;

<<

\ struct-element-constructor [
    (struct-element-constructor) [ ] curry
] 1 define-transform

>>