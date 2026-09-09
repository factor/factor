# F2 refresh of an older ARM64 image

The original root `factor.image` reproduces the reported F2 failure:
`compiler.cfg.builder.alien` cannot find `^^callback-stack` while loading
`emit-va-cursor-inputs`. `before.log` records the actual failing process
(exit 1), using the original root VM and image.

The instruction vocabulary already regenerates its generated consumers.
However, regenerating `compiler.cfg.hats` can re-enter the compiler before
the newly added helper has been defined. At the point of failure,
`##callback-stack` and its constructor already exist, while the helper does not.
The builder now uses `next-vreg dup ##callback-stack,`, the exact expansion
of that single-output helper, so it can compile during regeneration.

`after.log` runs the same `refresh.factor` against the same old executable
and image with the builder fix: refresh completes with zero compiler errors
and process exit 0. `tests.log` passes all 20 builder/instruction checks,
including a new regression that removes the helper, reloads the builder,
emits the instruction, and restores the generated helpers afterward.

The separate [lazy callback-template regression](../lazy-arm64-callback-template-20260908/README.md)
verifies the next step: an older image's native callback template is upgraded
on the first variadic callback, after checking that the VM supports it.
The independent C caller fails before that change and passes afterward;
ordinary callbacks and the original template entries survive the upgrade and GC.
An incompatible VM still rejects the request without changing the template.

## Root executable

The original root executable did not export
`arm64_variadic_callbacks_supported`. It was saved as
`/tmp/factor-before-refresh-fix-20260908`, then rebuilt from current VM source
with `make -j4 macos-arm-64`. `build.log` records the successful build and
application signing. The rebuilt executable exports the required entry point.
The root `factor.image` was not overwritten.

The running listener must be restarted to use the rebuilt native executable;
F2 reloads Factor source, not native machine code. Abort the old error, restart
Factor, then press F2.

## Reproduction

```sh
./factor -i=factor.image -no-user-init -no-monitors \
  reference/refresh-varargs-20260908/refresh.factor
./factor -i=/path/to/current-compatible.image -resource-path="$PWD" \
  -no-user-init -no-monitors reference/refresh-varargs-20260908/tests.factor
./factor -i=factor.image -no-user-init -no-monitors \
  reference/refresh-varargs-20260908/end-to-end.factor
```

`end-to-end.factor` uses the rebuilt root executable and original root image:
it refreshes all changed source, checks for compiler errors, then runs the
native lazy-template regression in that same process. Its fixture is the
native `libfactor-ffi-test.dylib` rebuilt alongside the VM.
`end-to-end.log` records a clean refresh followed by all four native callback
checks passing, with process exit 0.

For baseline reproduction, use the pre-fix source at `5fa90c067d` in an
isolated checkout and the original old image. Saved images and executables
are excluded from the evidence commits.
