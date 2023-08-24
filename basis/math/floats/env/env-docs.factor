! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math.floats.env quotations ;
IN: math.floats.env

HELP: fp-exception
{ $class-description "Symbols of this type represent floating-point exceptions. They are used to get and set the floating-point unit's exception flags (using " { $link fp-exception-flags } " and " { $link set-fp-exception-flags } ") and to control processor traps (using " { $link with-fp-traps } "). The following symbols are defined:"
{ $list
{ { $link +fp-invalid-operation+ } " indicates that an invalid floating-point operation occurred, such as taking the square root of a negative number or dividing zero by zero." }
{ { $link +fp-overflow+ } " indicates that a floating-point operation gave a result larger than the maximum representable value of the type used to perform the calculation." }
{ { $link +fp-underflow+ } " indicates that a floating-point operation gave a result smaller than the minimum representable normalized value of the type used to perform the calculation." }
{ { $link +fp-zero-divide+ } " indicates that a floating-point division by zero was attempted." }
{ { $link +fp-inexact+ } " indicates that a floating-point operation gave an inexact result that needed to be rounded." }
} } ;

HELP: +fp-invalid-operation+
{ $class-description "This symbol represents a invalid operation " { $link fp-exception } "." } ;
HELP: +fp-overflow+
{ $class-description "This symbol represents an overflow " { $link fp-exception } "." } ;
HELP: +fp-underflow+
{ $class-description "This symbol represents an underflow " { $link fp-exception } "." } ;
HELP: +fp-zero-divide+
{ $class-description "This symbol represents a division-by-zero " { $link fp-exception } "." } ;
HELP: +fp-inexact+
{ $class-description "This symbol represents an inexact result " { $link fp-exception } "." } ;

HELP: fp-rounding-mode
{ $class-description "Symbols of this type represent floating-point rounding modes. They are passed to the " { $link with-rounding-mode } " word to control how inexact values are calculated when exact results cannot fit in a floating-point type. The following symbols are defined:"
{ $list
{ { $link +round-nearest+ } " rounds the exact result to the nearest representable value, using the even value when the result is halfway between its two nearest values." }
{ { $link +round-zero+ } " rounds the exact result toward zero, that is, down for positive values, and up for negative values." }
{ { $link +round-down+ } " always rounds the exact result down." }
{ { $link +round-up+ } " always rounds the exact result up." }
} } ;

HELP: +round-nearest+
{ $class-description "This symbol represents the round-to-nearest " { $link fp-rounding-mode } "." } ;
HELP: +round-zero+
{ $class-description "This symbol represents the round-toward-zero " { $link fp-rounding-mode } "." } ;
HELP: +round-down+
{ $class-description "This symbol represents the round-down " { $link fp-rounding-mode } "." } ;
HELP: +round-up+
{ $class-description "This symbol represents the round-up " { $link fp-rounding-mode } "." } ;

HELP: fp-denormal-mode
{ $class-description "Symbols of this type represent floating-point denormal modes. They are passed to the " { $link with-denormal-mode } " word to control whether denormals are generated as outputs of floating-point operations and how they are treated when given as inputs."
{ $list
{ { $link +denormal-keep+ } " causes denormal results to be generated and accepted as inputs as required by IEEE 754." }
{ { $link +denormal-flush+ } " causes denormal results to be flushed to zero and be treated as zero when given as inputs. This mode may allow floating point operations to give results that are not compliant with the IEEE 754 standard." }
} } ;

HELP: +denormal-keep+
{ $class-description "This symbol represents the IEEE 754 compliant keep-denormals " { $link fp-denormal-mode } "." } ;
HELP: +denormal-flush+
{ $class-description "This symbol represents the non-IEEE-754-compliant flush-denormals-to-zero " { $link fp-denormal-mode } "." } ;

HELP: fp-exception-flags
{ $values { "exceptions" { $sequence fp-exception } } }
{ $description "Returns the set of floating-point exception flags that have been raised." } ;

HELP: set-fp-exception-flags
{ $values { "exceptions" { $sequence fp-exception } } }
{ $description "Replaces the set of floating-point exception flags with the set specified in " { $snippet "exceptions" } "." }
{ $notes "On Intel platforms, the legacy x87 floating-point unit does not support setting exception flags, so this word only clears the x87 exception flags. However, the SSE unit's flags are set as expected." } ;

HELP: clear-fp-exception-flags
{ $description "Clears all of the floating-point exception flags." } ;

HELP: collect-fp-exceptions
{ $values { "quot" quotation } { "exceptions" { $sequence fp-exception } } }
{ $description "Clears the floating-point exception flags and then calls " { $snippet "quot" } ", returning the set of floating-point exceptions raised during its execution and placing them on the datastack on " { $snippet "quot" } "'s completion." } ;

{ fp-exception-flags set-fp-exception-flags clear-fp-exception-flags collect-fp-exceptions } related-words

HELP: denormal-mode
{ $values { "mode" fp-denormal-mode } }
{ $description "Returns the current floating-point denormal mode." } ;

HELP: with-denormal-mode
{ $values { "mode" fp-denormal-mode } { "quot" quotation } }
{ $description "Sets the floating-point denormal mode to " { $snippet "mode" } " for the dynamic extent of " { $snippet "quot" } ", restoring the denormal mode to its original value on " { $snippet "quot" } "'s completion." } ;

{ denormal-mode with-denormal-mode } related-words

HELP: rounding-mode
{ $values { "mode" fp-rounding-mode } }
{ $description "Returns the current floating-point rounding mode." } ;

HELP: with-rounding-mode
{ $values { "mode" fp-rounding-mode } { "quot" quotation } }
{ $description "Sets the floating-point rounding mode to " { $snippet "mode" } " for the dynamic extent of " { $snippet "quot" } ", restoring the rounding mode to its original value on " { $snippet "quot" } "'s completion." } ;

{ rounding-mode with-rounding-mode } related-words

HELP: fp-traps
{ $values { "exceptions" { $sequence fp-exception } } }
{ $description "Returns the set of floating point exceptions with processor traps currently set." } ;

HELP: with-fp-traps
{ $values { "exceptions" { $sequence fp-exception } } { "quot" quotation } }
{ $description "Clears the floating-point exception flags and replaces the exception mask, enabling processor traps for the set of exception conditions specified in " { $snippet "exceptions" } " for the dynamic extent of " { $snippet "quot" } ". The original exception mask is restored on " { $snippet "quot" } "'s completion." } ;

HELP: without-fp-traps
{ $values { "quot" quotation } }
{ $description "Disables all floating-pointer processor traps for the dynamic extent of " { $snippet "quot" } ", restoring the original exception mask on " { $snippet "quot" } "'s completion." } ;

{ fp-traps with-fp-traps without-fp-traps vm-error>exception-flags vm-error-exception-flag? } related-words

HELP: vm-error>exception-flags
{ $values { "error" "a floating-point error object from the Factor VM" } { "exceptions" { $sequence fp-exception } } }
{ $description "When a floating-point trap is raised, the Factor VM reports the trap by throwing a Factor exception containing the exception flags at the time the trap was raised. This word extracts the exception flag information from " { $snippet "error" } " and converts it into a sequence of " { $link fp-exception } "s." } ;

HELP: vm-error-exception-flag?
{ $values { "error" "a floating-point error object from the Factor VM" } { "flag" fp-exception } { "?" boolean } }
{ $description "When a floating-point trap is raised, the Factor VM reports the trap by throwing a Factor exception containing the exception flags at the time the trap was raised. This word returns a boolean indicating whether the exception " { $snippet "flag" } " was raised at the time " { $snippet "error" } " was thrown." } ;

ARTICLE: "math.floats.env" "Controlling the floating-point environment"
"The " { $vocab-link "math.floats.env" } " vocabulary contains words for querying and controlling the floating-point environment."
$nl
"Querying and setting exception flags:"
{ $subsections
    fp-exception-flags
    set-fp-exception-flags
    clear-fp-exception-flags
    collect-fp-exceptions
}
"Querying and controlling processor traps for floating-point exceptions:"
{ $subsections
    fp-traps
    with-fp-traps
    without-fp-traps
}
"Getting the floating-point exception state from errors raised by enabled traps:"
{ $subsections
    vm-error>exception-flags
    vm-error-exception-flag?
}
"Querying and controlling the rounding mode and treatment of denormals:"
{ $subsections
    rounding-mode
    with-rounding-mode
    denormal-mode
    with-denormal-mode
} ;

ABOUT: "math.floats.env"
