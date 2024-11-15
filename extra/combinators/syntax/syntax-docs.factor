USING: help.markup help.syntax combinators kernel generalizations ;
IN: combinators.syntax

HELP: &[
    { $syntax "&[ A | B | C ]"  } 
    { $description { "Applies quotations (separated by " { $link \ | } ") to the first value on the stack one by one, restoring the original value to the top of the stack each time"  }  }
    { $see-also \ cleave \ bi } ;

HELP: *[
    { $syntax "*[ A | B | C ]"  } 
    { $description { "Applies quotations (separated by " { $link \ | } ") to successive values on the stack, applying the first quotation to the first value, the second to the second value, and so on" } }
    { $see-also \ spread \ bi* } ;

HELP: @[
    { $syntax "N @[ A ]" }
    { $description "Applies a quotation to the top N values on the stack" }
    { $see-also \ napply \ bi@ } ;

HELP: n&[
     { $syntax "N n&[ A | B | C ]" }
     { $description "Applies quotations (separated by " { $link \ | } ") to the first N values on the stack, restoring the original values to the top of the stack each time" }
     { $see-also POSTPONE: &[ \ ncleave \ bi } ;

HELP: n*[
    { $syntax "N n*[ A | B | C ]" }
    { $description "Applies quotations (separated by " { $link \ | } ") to successive N sized groups on the stack, applying the first quotation to the first N values, the second to the second N values, and so on" }
    { $see-also POSTPONE: *[ \ nspread \ bi* } ;

HELP: n@[
    { $syntax "M N n@[ A ]" }
    { $description "Applies a quotation to the top N groups of size M on the stack" }
    { $see-also POSTPONE: @[ \ mnapply \ bi@ } ;

HELP: |
{ $description "Delimiter in combinator syntax expressions." } ;

