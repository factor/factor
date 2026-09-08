! Intentional negative control for the real shared CI runner.
USING: namespaces parser tools.test ;
f restartable-tests? set-global
"resource:reference/arm64-gap-ci-20260908/failing-test.factor" run-test-file
"resource:.github/arm64-tests.factor" run-file
