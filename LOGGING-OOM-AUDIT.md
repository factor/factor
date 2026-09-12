# Server startup OOM and log rotation — 2026-09-12

The user journal records kernel OOM kills for the website's tmux scopes at
14:08:04, 14:13:11, and 14:15:10 UTC, each reporting a 1.6 GB memory peak.
Tmux itself survived. Its pane scopes use `OOMPolicy=stop`, which explains
the shell/window disappearing along with the affected process.

Each failed startup logged an Insomniac report attempt. Insomniac's `every`
timer runs immediately, and `analyze-log-file` previously called
`parse-log-file`, which loaded every line and retained every parsed entry.
The HTTP log was approximately 1.8 GiB. Rotation happened only after reporting,
so killing the process left the same backlog for the next startup.
Restoring `http-insomniac` exposed this previously disabled path.

## Fixes

* `6a16566eae` bounds file reports to the newest 1 MiB by default, configurable
  through `logging.analysis:log-report-limit`. The raw read is bounded even
  for an oversized line without a newline. A partial first line is removed
  before UTF-8 decoding, and reports explicitly state omitted bytes and the
  limited scope of their counts. The explicit full-file parser remains
  available. Multiline detection now checks the timestamp slot, joining
  continuation lines to the preceding entry instead of counting separate hits.
* `b318837b2f` makes the log server rotate an individual service before its
  next message once its active file reaches 10 MiB. This global setting is
  `logging.server:max-log-size`; `f` disables size-based rotation. Retention
  remains ten numbered files. Entries stay intact, so a file can exceed the
  threshold by one message. Insomniac also requests rotation in `finally`,
  including when reporting fails.

The old audit backups and downloaded toolchain occupied about 1.25 GiB on
this machine's RAM-backed `/tmp`. They were moved, with file hashes verified,
to `/home/sheeple/factor-audit-artifacts/`. Symlinks preserve their old paths.
This reduced `/tmp` usage from about 1.4 GiB to 152 MiB and increased available
memory from about 1.6 GiB to 2.8 GiB at the observed checks.

## Validation and deployment

All 26 logging checks and logging documentation lint pass. Regressions cover
UTF-8 boundaries, oversized and unterminated lines, partial-report notices,
multiline entries, existing backlogs, independent service rotation, ten-file
retention, and rotation after a thrown report error. Tests use temporary logs
and do not send email.

A read-only report against the real 1.8 GiB HTTP log completed in 1.64 seconds
with 189,476 KiB maximum RSS (about 185 MiB). The production logs were neither
rotated nor deleted during validation. Logs and statuses are in
`/tmp/factor-logging-*.log`, `.time`, and `.status`.

The rebuilt `factor.image` passed all logging checks and was installed for the
user's restart. The native executable is unchanged. Its previous image and
executable, with a checksum manifest, are backed up at:

```
/home/sheeple/factor-audit-artifacts/before-logging-20260912T142908Z/
```

Insomniac remains enabled. The production server was not started by this audit.
