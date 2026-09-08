USING: accessors assocs compiler.errors debugger io kernel memory
namespaces parser prettyprint sequences vocabs.loader ;
"reference/arm64-gap-isa-20260908/reload.factor" run-file
compiler-errors get values [ print-error ] each
compiler-errors get assoc-size . flush
"isa-ready.image" save-image-and-exit
