USING: kernel stack-checker.transforms ;
IN: struct-arrays.private

: struct-element-constructor ( c-type -- word )
    "Struct array usages must be compiled" throw ;

<<

\ struct-element-constructor [
    (struct-element-constructor) [ ] curry
] 1 define-transform

>>