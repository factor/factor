USING: cpu.arm.64.features kernel sequences system tools.test
windows-feature-persistence-test ;
{ "fallback" } [ saved-dispatch ] unit-test
{ f } [ "saved-image-only" detected-arm64-features member? ] unit-test
{ t } [ detected-arm64-features probe-arm64-features = ] unit-test
