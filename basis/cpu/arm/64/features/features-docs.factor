USING: help.markup help.syntax sequences words ;
IN: cpu.arm.64.features

HELP: arm64-features
{ $values { "features" sequence } }
{ $description "Returns the optional ARM64 features detected for this process, excluding disabled features. Supported names are dotprod, fp16, bf16 and i8mm. Detection is reset when an image starts." } ;

HELP: disabled-arm64-features
{ $var-description "A sequence of optional ARM64 feature names to disable. This can remove detected capabilities but cannot enable unsupported instructions. The command-line option -disable-neon-extensions disables all four optional feature families." } ;

HELP: arm64-kernel-requirements
{ $values { "word" word } { "features" sequence } }
{ $description "Returns a kernel's required-arm64-features metadata, or an empty sequence for an unannotated word. Optional kernels are private and are reached through runtime-checked public operations." } ;
