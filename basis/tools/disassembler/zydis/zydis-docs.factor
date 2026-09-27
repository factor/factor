USING: help.markup help.syntax ;
IN: tools.disassembler.zydis

ARTICLE: "tools.disassembler.zydis" "Zydis disassembler backend"
"The " { $vocab-link "tools.disassembler.zydis" } " vocabulary provides an optional x86 and x86-64 backend for " { $vocab-link "tools.disassembler" } ". It requires the Zydis 4.1 shared library. Library lookup uses the platform's search paths, including versioned libraries on Linux and Homebrew and MacPorts installations on macOS. On Windows, install Zydis.dll beside Factor or on PATH."
$nl
"Load the vocabulary to select it as the disassembler backend:"
{ $code "USE: tools.disassembler.zydis" }
"Instructions are formatted in Intel syntax. Decoding stops at the first invalid or incomplete instruction. The default mode is 64-bit on a 64-bit Factor VM and 32-bit on a 32-bit VM; this backend only decodes x86 machine code." ;

ABOUT: "tools.disassembler.zydis"
