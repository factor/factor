# Resource cleanup and continuation audit — 2026-09-11

Mason's package and release actions leaked one SQLite connection whenever
parameter validation failed. Both actions opened `with-mason-db` before calling
`validate-os/cpu`. `validation-failed` returns HTTP 400 using `exit-with`, which
restores a continuation without unwinding the intervening `with-db` and
`with-transaction` scopes. Neither connection disposal nor transaction cleanup
ran. The connection remained in the disposable registry, so garbage collection
could not recover it. This produced ordinary 400 responses, not error log entries.

## Fix and reproduction

Both initializers now validate before opening the database. In a separate Factor
process, 20 invalid requests to the actual action implementations increased the
descriptor count from 19 to 39 before the fix, leaving 20 database connections.
Afterward, the same requests left 19 descriptors and zero database connections.
The request regression fails against the original definitions and passes against
the fixed definitions.

Four malformed requests in the current production process's lifetime reach these
paths, matching its four persistent Mason descriptors: `/release/.env`, a release
URL with `amp;cpu` instead of `cpu`, `/release`, and `/package` without parameters.
The older `openfiles.log` contains 821 Mason descriptors, but is dated September
2025; it is not a snapshot of the September 2026 EMFILE event.

## Scope and other call sites

Searched the `core`, `basis`, and `extra` source trees for `with-db`,
`with-transaction`, `with-disposal`, and `with-destructors`, their wrappers, and
continuation exits. The initial resource search produced 327 candidate source
lines, including definitions, comments, and fixtures. Traced direct `exit-with`
callers and indirect validation/login helpers, rather than relying on words
appearing together in one source file.

| Area | Result |
| --- | --- |
| Mason actions and maintenance | Fixed package/release validation. Report, benchmark, status update, release creation, and other validation run before their local database scopes. Grid, counter, dashboard, and maintenance scopes contain no Furnace early exit. |
| Blogs and pastebin transactions | Validation and author authorization finish before transaction entry. Their transaction bodies perform database operations; redirects follow transaction completion. |
| Wiki, Planet, todo, calculator, FJSC, URL shortener, site-watcher, user administration | No additional local resource scope crossed by validation exits was found. Database initialization and background tasks are separate from action validation. |
| Authentication and reCAPTCHA | Password/username/login failures occur after database queries or transactions return. reCAPTCHA validation exits before its HTTP request or after that request has completed and released its resources. |
| Furnace pooled persistence and request cleanup | The HTTP request's destructor scope encloses the action's continuation capture. Early exits return into that outer scope; deferred connection return and request cleanup still run. New regressions cover both validation and login exits. |
| SQL query/statement helpers, persistency, MongoDB, site-watcher database wrappers | Quotation-taking helpers retain the same cleanup contract. No additional in-repository Furnace escape crossing these wrappers was found. |
| Native allocation, socket, file, image, compression, crypto, platform, and GUI helpers | Checked resource entry points against the escape paths. No additional concrete instance of the Mason pattern was found. Generic callback-taking helpers can still be misused by caller-supplied nonlocal exits. |
| Listener/curses/TTY returns, compiler and prettyprinter returns, GML, logic/backtracking, coroutine/generator/partial-continuation APIs | Reviewed continuation capture/transfer boundaries. No additional in-repository native-resource leak of this pattern was established. Suspension and intentional continuation restoration were not changed to exception unwinding. |

This is a source audit with Linux regression testing, not an exhaustive proof for
arbitrary runtime quotations or every platform. Raw continuation restoration
still bypasses intervening cleanup by design. Changing that behavior globally
would affect backtracking, resumption, and user exception handlers. The existing
`destructors-continuations` documentation explains the safe scope placement;
Furnace and database documentation now state the same limitation explicitly.

## Validation and deployment

- Mason request regressions cover missing parameters, a malformed query key,
  trailing path components, and newline-containing values. They use a temporary
  database, verify 400 responses, and check that no connections remain.
- Furnace database regressions run 20 validation exits and 20 login exits and
  verify successful reuse of one pooled connection.
- Pool, SQLite, Furnace, static HTTP, multipart, SMTP, and Mason tests pass. The
  existing SMTP mock server can report a broken pipe during TLS teardown despite
  a successful suite exit; this is not evidence of a new TLS fix.

The running website must be restarted or its existing action objects explicitly
rebuilt. Refreshing the constructor words alone does not replace the old `init`
quotations already stored in those objects. The code fix does not reclaim
connections leaked earlier in that process; a restart releases them.
