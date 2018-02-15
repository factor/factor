USING: io.pathnames llvm.reader llvm.wrappers tools.test ;

{ t } [
    "resource:extra/llvm/wrappers/add.bc" absolute-path load-module
    module?
] unit-test
