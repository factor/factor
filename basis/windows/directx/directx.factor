USING: alien sequences alien.libraries alien.libraries.finder ;
IN: windows.directx

{
    { "dinput"      "dinput8.dll"        stdcall }
    { "dxgi"        "dxgi.dll"           stdcall }
    { "d2d1"        "d2d1.dll"           stdcall }
    { "d3d9"        "d3d9.dll"           stdcall }
    { "d3d10"       "d3d10.dll"          stdcall }
    { "d3d10_1"     "d3d10_1.dll"        stdcall }
    { "d3d11"       "d3d11.dll"          stdcall }
    { "d3dcompiler" "d3dcompiler_42.dll" stdcall }
    { "d3dcsx"      "d3dcsx_42.dll"      stdcall }
    { "d3dx9"       "d3dx9_42.dll"       stdcall }
    { "d3dx10"      "d3dx10_42.dll"      stdcall }
    { "d3dx11"      "d3dx11_42.dll"      stdcall }
    { "dwrite"      "dwrite.dll"         stdcall }
    { "x3daudio"    "x3daudio1_6.dll"    stdcall }
    { "xactengine"  "xactengine3_5.dll"  stdcall }
    { "xapofx"      "xapofx1_3.dll"      stdcall }
    { "xaudio2"     "xaudio2_5.dll"      stdcall }
} [ first3 add-library ] each

"xinput" { "xinput1_4.dll" "xinput1_3.dll" } find-library-from-list stdcall add-library
