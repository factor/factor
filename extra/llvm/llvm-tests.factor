USING: kernel literals llvm llvm.ffi system tools.test ;

${ cpu x86.64? "x86-64" "x86-32" ? } [
    initialize-native-target
    LLVMGetFirstTarget LLVMGetTargetName
] unit-test
