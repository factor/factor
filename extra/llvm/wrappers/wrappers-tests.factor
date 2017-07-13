USING: accessors alien destructors io.pathnames kernel llvm.ffi
llvm.reader llvm.wrappers tools.test ;
IN: llvm.wrappers.tests

CONSTANT: ADD.BC "resource:extra/llvm/wrappers/add.bc"

{ 728 t } [
    ADD.BC absolute-path <buffer>
    [ value>> [ LLVMGetBufferSize ] keep ] with-disposal alien?
] unit-test

{ "sum" 2 } [
    ADD.BC absolute-path load-module <engine>
    "sum" find-function [ LLVMGetValueName ] [ LLVMCountParams ] bi
] unit-test
