USING: help.markup help.syntax math.functions math ;
IN: math.libm

ARTICLE: "math.libm" "C standard library math functions"
"The words in the " { $vocab-link "math.libm" } " vocabulary call C standard library math functions. They are used to implement words in the " { $vocab-link "math.functions" } " vocabulary."
{ $warning
"These functions are unsafe. The compiler special-cases them to operate on floats only. They can be called directly, however there is little reason to do so, since they only implement real-valued functions, and in some cases place restrictions on the domain:"
{ $example "USE: math.functions" "2.0 acos ." "C{ 0.0 1.3169578969248166 }" }
{ $unchecked-example "USE: math.libm" "2.0 facos ." "0/0." } }
"Trigonometric functions:"
{ $subsections
    fcos
    fsin
    facos
    fasin
    fatan
    fatan2
}
"Hyperbolic functions:"
{ $subsections
    fcosh
    fsinh
}
"Exponentials and logarithms:"
{ $subsections
    fexp
    flog
    flog10
}
"Powers:"
{ $subsections
    fpow
    fsqrt
} ;

ABOUT: "math.libm"

HELP: facos
{ $values { "x" real } { "double" real } }
{ $description "Calls the inverse trigonometric cosine function from the C standard library. User code should call " { $link acos } " instead." } ;

HELP: fasin
{ $values { "x" real } { "double" real } }
{ $description "Calls the inverse trigonometric sine function from the C standard library. User code should call " { $link asin } " instead." } ;

HELP: fatan
{ $values { "x" real } { "double" real } }
{ $description "Calls the inverse trigonometric tangent function from the C standard library. User code should call " { $link atan } " instead." } ;

HELP: fatan2
{ $values { "x" real } { "y" real } { "double" real } }
{ $description "Calls the two-parameter inverse trigonometric tangent function from the C standard library. User code should call " { $link arg } " instead." } ;

HELP: fcos
{ $values { "x" real } { "double" real } }
{ $description "Calls the trigonometric cosine function from the C standard library. User code should call " { $link cos } " instead." } ;

HELP: fsin
{ $values { "x" real } { "double" real } }
{ $description "Calls the trigonometric sine function from the C standard library. User code should call " { $link sin } " instead." } ;

HELP: fcosh
{ $values { "x" real } { "double" real } }
{ $description "Calls the hyperbolic cosine function from the C standard library. User code should call " { $link cosh } " instead." } ;

HELP: fsinh
{ $values { "x" real } { "double" real } }
{ $description "Calls the hyperbolic sine function from the C standard library. User code should call " { $link sinh } " instead." } ;

HELP: fexp
{ $values { "x" real } { "double" real } }
{ $description "Calls the exponential function (" { $snippet "y=e^x" } ") from the C standard library. User code should call " { $link e^ } " instead." } ;

HELP: flog
{ $values { "x" real } { "double" real } }
{ $description "Calls the natural logarithm function from the C standard library. User code should call " { $link log } " instead." } ;

HELP: flog10
{ $values { "x" real } { "double" real } }
{ $description "Calls the base 10 logarithm function from the C standard library. User code should call " { $link log10 } " instead." } ;

HELP: fpow
{ $values { "x" real } { "y" real } { "double" real } }
{ $description "Calls the power function (" { $snippet "z=x^y" } ") from the C standard library. User code should call " { $link ^ } " instead." } ;

HELP: fsqrt
{ $values { "x" real } { "double" real } }
{ $description "Calls the square root function from the C standard library. User code should call " { $link sqrt } " instead." } ;

HELP: ffma
{ $values { "x" real } { "y" real } { "z" real } { "double" real } }
{ $description "Calls the " { $snippet "fma" } " function from the C standard library to compute the 'fused-multiply-add' result of " { $snippet "(x * y) + z" } ". User code should call " { $link fma } " instead." } ;
