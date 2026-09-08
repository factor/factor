USING: help.markup help.syntax math ;
IN: math.floats.small

ARTICLE: "small-float-memory-types" "Small floating-point memory types"
"The " { $vocab-link "math.floats.small.c-types" } " vocabulary defines two-byte half and bfloat memory element types. They can be used with alien memory accessors. On ARM64, scalar calls by value use the C _Float16 and __bf16 conventions; direct calls, indirect calls and callbacks are supported when the C toolchain supports these types. Values convert numerically, using round-to-nearest ties-to-even and canonical NaNs. Windows ARM64 variadic signatures pass named and anonymous scalar half/BF16 payloads through the general-purpose argument registers and stack. Other architectures retain memory-only support." ;

HELP: float>half-bits
{ $values { "x" real } { "bits" integer } }
{ $description "Encodes IEEE binary16 with round-to-nearest, ties-to-even. Conversion is direct from binary64, independent of the host rounding mode. Signed zeros, infinities and subnormals are preserved. NaNs become 0x7e00." } ;
HELP: half-bits>float
{ $values { "bits" integer } { "x" float } }
{ $description "Decodes the low 16 bits as IEEE binary16. Finite values are exact; NaNs become a canonical quiet NaN." } ;
HELP: float>bfloat-bits
{ $values { "x" real } { "bits" integer } }
{ $description "Encodes BF16 directly from binary64 with round-to-nearest, ties-to-even, independent of the host rounding mode. NaNs become 0x7fc0." } ;
HELP: bfloat-bits>float
{ $values { "bits" integer } { "x" float } }
{ $description "Decodes the low 16 bits as BF16. Finite values are exact; NaNs become a canonical quiet NaN." } ;
