USING: accessors alien compiler.units kernel
llvm.bindings llvm.core tools.test words ;

IN: scratchpad

: add-abi ( x y -- x+y ) ! to be filled in by llvm
    drop ;

: llvm-add ( x y -- x+y )
    "test" <module> [
        {
            { [ 32 LLVMIntType ] "add" }
            { [ 32 LLVMIntType ] "x" }
            { [ 32 LLVMIntType ] "y" }
        } <function> [
            "entry" <builder> [
                builder value>> "x" get-param "y" get-param "sum" LLVMBuildAdd
                builder value>> swap LLVMBuildRet drop
            ] with-builder
        ] with-function
        
        <engine>
    ] with-module
    
    [
        "add" find-function global>pointer
        [ "int" { "int" "int" } "cdecl" alien-indirect ] curry \ add-abi swap
        (( x y -- x+y )) [ define-declared ] with-compilation-unit
        add-abi ! call our new word
    ] with-engine ; inline

[ 7 ] [ 3 4 llvm-add ] unit-test