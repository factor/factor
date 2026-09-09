# Lazy ARM64 callback-template upgrade

Native macOS ARM64 fail-before/pass-after verification, 2026-09-08. Source is `5fa90c067d` plus the builder refresh-cycle fix subsequently committed as `c5eb3865ef`, and this change to `stack-checker.alien`. The builder dependency was copied for validation and is excluded from this commit.

Ordinary live refresh updates compiler definitions but does not run stage2's `bootstrap.compat.arm64` loader. An older image therefore retains the ordinary two-item callback template, and a compatible VM still rejects the first variadic callback. The runtime check now verifies the VM export first, then lazily requires the existing compatibility loader only when the third template item is missing. The loader preserves the original ordinary code and relocation objects. Existing templates are reused; unsupported VMs still fail before any upgrade attempt.

## Evidence

- `prepare.log`: actual old root `factor.image` successfully runs `refresh-all` with the builder fix, leaves zero compiler errors and a two-item callback template, and saves a private prepared image. No root image is overwritten.
- `before.log`: with the verified compatible VM and that prepared image, the independent native C control returns 255, but the actual variadic callback test fails with `variadic-callback-runtime-required` (process exit 1).
- `after.log` and `after-no-intrinsics.log`: reloading only the changed `stack-checker.alien` source makes all four native tests pass (exit 0 in both modes). A live ordinary callback returns 42 before the upgrade and again after GC. The C fixture enters a variadic callback and gets the expected weighted sum 78. Both original ordinary-template entries retain object identity, the template grows to three items, and another variadic allocation returns 78 without replacing the installed template.
- `incompatible.log`: the copied old VM has no `arm64_variadic_callbacks_supported` export. Three ordinary assertions and one expected-failure assertion pass (exit 0), confirming `variadic-callback-runtime-required` is raised and the template stays at length two.

The C entry and independent control are the existing `va_call_ints`/`va_c_controls` in `vm/ffi_test_varargs.c`; no mock FFI implementation is used. The regression intentionally requires a legacy two-item image template and therefore runs in its own process, rather than removing a template that another test's live variadic callbacks might still need.

## Reproduction

Local isolated tree: `/Users/erg/factor.worktrees/lazy-arm64-callback-template`.
Compatible VM: `/Users/erg/factor.worktrees/arm64-varargs-entry/factor` (export confirmed with nm). Old VM is copied as `factor-old-runtime` before root rebuild. The fixture is linked as `libfactor-ffi-test.dylib` from root's existing native library.

First run `prepare.factor` against the old image with the builder fix and the pre-change runtime check still in the source tree:

```sh
/Users/erg/factor.worktrees/arm64-varargs-entry/factor -i=/Users/erg/factor/factor.image -resource-path=/Users/erg/factor.worktrees/lazy-arm64-callback-template -no-user-init -no-monitors reference/lazy-arm64-callback-template-20260908/prepare.factor
```

The private prepared image contains the original check. Applying the source change does not silently update it. These commands compare exactly that image before and after explicitly reloading the changed check:

```sh
# Expected exit 1, missing template before the fix
/Users/erg/factor.worktrees/arm64-varargs-entry/factor -i=prepared.image -resource-path=/Users/erg/factor.worktrees/lazy-arm64-callback-template -no-user-init -no-monitors reference/lazy-arm64-callback-template-20260908/callback-tests.factor
# Expected exit 0
/Users/erg/factor.worktrees/arm64-varargs-entry/factor -i=prepared.image -resource-path=/Users/erg/factor.worktrees/lazy-arm64-callback-template -no-user-init -no-monitors reference/lazy-arm64-callback-template-20260908/after.factor
/Users/erg/factor.worktrees/arm64-varargs-entry/factor -i=prepared.image -resource-path=/Users/erg/factor.worktrees/lazy-arm64-callback-template -no-user-init -no-monitors -no-intrinsics reference/lazy-arm64-callback-template-20260908/after.factor
./factor-old-runtime -i=prepared.image -resource-path=/Users/erg/factor.worktrees/lazy-arm64-callback-template -no-user-init -no-monitors reference/lazy-arm64-callback-template-20260908/incompatible.factor
```

SHA256 inputs/results:

| Artifact | SHA256 |
| --- | --- |
| Original root factor.image | `2846d741214dae1cd6217273377c4deac6052c8af9710a8a2d7d540a9f2b2e95` |
| Private prepared.image | `41129df732e8e5a55ceb8c6eb8a17d9bb4fe2a0da8f693663fdb3adbde822ca2` |
| Compatible C++ VM | `fb29a522874a01d4942981354f8953caa56d76387e8c5de3b7a2ec5af04bcc42` |
| Copied old VM | `67f8f4c96bec8dfd2d8758c82639aa5a1acf35fb26fb936ce86bb2f2e3e37ed2` |
| Native C fixture | `3b56aa71e5f176840b5a017c8c46c3b2cc38e5a9cbdb2ace68ec32221f428c30` |
