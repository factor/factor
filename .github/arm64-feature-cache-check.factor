USING: arm64-feature-cache-test cpu.arm.64.features io kernel sequences system ;

saved-feature-dispatch "fallback" =
[ "Compiled feature dispatch retained the saved process cache" throw ] unless
"saved-image-only" detected-arm64-features member?
[ "Saved process capability survived startup" throw ] when
detected-arm64-features probe-arm64-features =
[ "Cached capabilities differ from the current process probe" throw ] unless
"ARM64 feature cache reset passed" print flush
0 exit
