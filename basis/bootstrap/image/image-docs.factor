USING: bootstrap.image.private byte-arrays help.markup help.syntax
io.pathnames kernel.private math quotations sequences strings vectors
words ;
IN: bootstrap.image

HELP: architecture
{ $var-description "Bootstrap architecture name" } ;

HELP: bootstrapping-image
{ $var-description "A " { $link vector } " holding the data of the generated image. For simplicity, each element holds 'cell' number of bytes." } ;

HELP: define-sub-primitive
{ $values { "quot" quotation } { "word" word } }
{ $description "Defines a sub primitive by running the quotation which is supposed to output assembler code. The word is then used to call the assembly." }
{ $see-also sub-primitives } ;

HELP: jit-define
{ $values { "quot" quotation } { "n" integer } }
{ $description "Runs a quotation generating assembly code. The code is added to the " { $link special-objects } " table being constructed for the bootstrap image." } ;

HELP: make-image
{ $values { "arch" string } }
{ $description "Creates a bootstrap image from sources, where " { $snippet "architecture" } " is one of the following:"
{ $code "\"windows-x86.32\"" "\"unix-x86.32\"" "\"windows-x86.64\"" "\"unix-x86.64\"" }
  "The new image file is written to the " { $link resource-path } " and is named " { $snippet "boot." { $emphasis "architecture" } ".image" } "." } ;

HELP: make-jit
{ $values
  { "quot" quotation }
  { "parameters" sequence }
  { "literals" sequence }
  { "code" "a { relocation insns } pair" }
}
{ $description "Runs the quotation to generate machine code. Code is a 2-tuple, where the first element is a " { $link byte-array } " of relocations and the second element the generated code." } ;

HELP: make-jit-no-params
{ $values
  { "quot" quotation }
  { "code" sequence }
}
{ $description "Like " { $link make-jit } ", except the assembler code can't contain any parameters. The word is used to generate the code templates (like " { $link JIT-3DIP } " that the JIT uses to compile quotations. The output is a two-tuple containing byte-arrays. The first item are the relocations and the second the machine code." } ;

HELP: sub-primitives
{ $var-description "An assoc that is set during bootstrapping. It contains symbols defining sub primitives as key, and generated assembly code for those symbols as values." } ;


ARTICLE: "bootstrap.image" "Bootstrapping new images"
"A new image can be built from source; this is known as " { $emphasis "bootstrap" } ". Bootstrap is a two-step process. The first stage is the creation of a bootstrap image from a running Factor instance:"
{ $subsections make-image make-my-image }
"The second bootstrapping stage is initiated by running the resulting bootstrap image:"
{ $code "./factor -i=boot.x86.32.image" }
"This stage loads additional code, compiles all words, and creates a final " { $snippet "factor.image" } "."
$nl
"The bootstrap process can be customized with command-line switches."
{ $see-also "runtime-cli-args" "bootstrap-cli-args" } ;

ABOUT: "bootstrap.image"
