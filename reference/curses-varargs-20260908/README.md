# Curses variadic binding verification

On ARM64 macOS, the four fixed-signature printw bindings passed their integer formatting argument in a register, while ncurses read its anonymous argument from the stack. The bindings now mark the ellipsis before the existing integer tail and preserve their stack arity.

`before.log` captures **four native failures**, with all four functions rendering the wrong integer (`value=11942` instead of the supplied positive/negative value). The correctly declared mixed string/double/int alias passes as an independent control. `baseline-headless.factor` preserves the original five checks. `after.log` reports **16 checks, zero test failures, zero compiler errors**, including the original va_list check, declaration metadata/stack effects, all four real printw variants, mixed and empty tails, and numeric/string tparm aliases. No checks were skipped locally.

The tests call the actual `libcurses.dylib` functions. `newterm("dumb", output, input)` receives two `tmpfile()` streams; a separate window is created with `newwin`, and `mvwinnstr` reads back its contents. Cleanup closes the window, screen, and files. No terminal display/input, GUI, or custom C fixture is required. Both logs contain zero terminal escape bytes. If the optional library or dumb terminfo entry is absent, the test reports the missing dependency explicitly.

The previously commented `tparm` binding is enabled with nine variadic `long` parameters, matching ncurses. `headers.txt` records the installed SDK's active declarations and `NCURSES_TPARM_VARARGS=1` / `NCURSES_TPARM_ARG=long`. The ncurses manual documents the variadic and legacy fixed-long alternatives; this vocabulary selects ncurses on supported Unix platforms. Typed aliases cover shorter lists and string parameters. No `tiparm` version dependency is introduced.

Sources: [ncurses printw manual](https://invisible-island.net/ncurses/man/curs_printw.3x.html), [ncurses terminfo manual](https://invisible-island.net/ncurses/man/curs_terminfo.3x.html).

Run the after harness from this worktree:

```
/Users/erg/factor.worktrees/arm64-varargs-entry/factor -resource-path=/Users/erg/factor.worktrees/varargs-curses -i=/Users/erg/factor/reference/arm64-varargs-20260908/final.image -no-user-init reference/curses-varargs-20260908/after.factor
```

The before harness ran at base `fa62cb4cb7` using the newly added headless file, before declaration changes. To reproduce against the final source, restore the four pre-change declarations in an isolated checkout, omit the new tparm documentation, and run `baseline-headless.factor`. No root source or root native fixture was modified.

The same final suite also passes under Rosetta x86-64: **16 checks, zero failures, zero compiler errors**, recorded in `x86-after.log`. It used `/Users/erg/factor.worktrees/arm64-gaps-x86/Factor.app/Contents/MacOS/factor` with `/Users/erg/factor.worktrees/arm64-varargs-x86/refreshed.image` and this worktree as the resource path. This independently checks the binding changes on the shared x86 backend; the fail-before ABI reproduction is ARM64 macOS.
