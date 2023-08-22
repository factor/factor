! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien help.markup help.syntax kernel sodium.ffi ;
IN: sodium

HELP: check-malloc
{ $values
  { "ptr" alien }
  { "ptr/*" alien }
}
{ $description "Check if " { $snippet "ptr" } " is " { $snippet "null" } " and throw " { $link sodium-malloc-error } " in that case. Otherwise simply leave " { $snippet "ptr" } " as is." } ;

HELP: sodium-malloc-error
{ $description "Throws a " { $link sodium-malloc-error } " error." }
{ $error-description "This error is thrown when " { $link sodium_malloc } " returns " { $snippet "null" } " due to memory allocation failure. Since each such allocation requires several pages of swap-protected memory, it is a limited resource in any OS." } ;
