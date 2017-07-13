USING: io.pathnames llvm.reader llvm.wrappers tools.test ;
IN: llvm.reader.tests

{ t } [
    "resource:extra/llvm/wrappers/add.bc" absolute-path load-module
    module?
] unit-test
