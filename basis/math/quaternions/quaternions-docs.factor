USING: help.markup help.syntax math ;
IN: math.quaternions

HELP: q+
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u+v" "a quaternion" } }
{ $description "Add quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 0 1 0 0 } { 0 0 1 0 } q+ ." "{ 0 1 1 0 }" } } ;

HELP: q-
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u-v" "a quaternion" } }
{ $description "Subtract quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 0 1 0 0 } { 0 0 1 0 } q- ." "{ 0 1 -1 0 }" } } ;

HELP: q*
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u*v" "a quaternion" } }
{ $description "Multiply quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 0 1 0 0 } { 0 0 1 0 } q* ." "{ 0 0 0 1 }" } } ;

HELP: qconjugate
{ $values { "u" "a quaternion" } { "u'" "a quaternion" } }
{ $description "Quaternion conjugate." } ;

HELP: qrecip
{ $values { "u" "a quaternion" } { "1/u" "a quaternion" } }
{ $description "Quaternion inverse." } ;

HELP: q/
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u/v" "a quaternion" } }
{ $description "Divide quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 0 0 0 1 } { 0 0 1 0 } q/ ." "{ 0 1 0 0 }" } } ;

HELP: q*n
{ $values { "q" "a quaternion" } { "n" real } { "r" "a quaternion" } }
{ $description "Multiplies each element of " { $snippet "q" } " by real value " { $snippet "n" } "." }
{ $notes "To multiply a quaternion with a complex value, use " { $link c>q } " " { $link q* } "." } ;

HELP: c>q
{ $values { "c" number } { "q" "a quaternion" } }
{ $description "Turn a complex number into a quaternion." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "C{ 0 1 } c>q ." "{ 0 1 0 0 }" } } ;

HELP: euler
{ $values { "phi" number } { "theta" number } { "psi" number } { "q" "a quaternion" } }
{ $description "Convert a rotation given by Euler angles (phi, theta, and psi) to a quaternion." } ;
