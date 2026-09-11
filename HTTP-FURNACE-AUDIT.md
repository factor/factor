# HTTP and Furnace audit

Follow-up to the descriptor-leak investigation, 2026-09-11.

## HTTP fixes

- Ordinary request bodies shared the 64 KiB request-header budget. A
  70,000-byte POST was delivered to the application as 65,370 bytes. Body
  reads now have their own validated Content-Length limit. Truncated plain
  and URL-encoded bodies are rejected before dispatch.
- EOF or the header limit could masquerade as the end of the headers.
  Requests now require the terminating empty line. The request-line parser
  also rejects trailing garbage and malformed versions instead of accepting
  a valid prefix or falling back to a simple request.
- Malformed headers, Host ports, line endings, and multipart structures
  could escape HTTP error handling. The identified parse failures now
  produce request errors and a 400 response. Multipart I/O failures retain
  their original exception type.
- Multipart boundary extraction now recognizes the parameter by name,
  including quoted values and parameters preceding the boundary.
- Transfer-Encoding was ignored when Content-Length was present, and on
  methods without body parsing. Such requests are now rejected. Decoding
  chunked request bodies remains unsupported.
- Ordinary responses with 1xx, 204, 205, or 304 status codes could execute
  and transmit body templates. They now suppress the body, as HEAD already
  did. Both string and numeric status codes are covered.

The completion review found and fixed three remaining cases:

- Multipart uploads now enforce the complete HTTP Content-Length, including
  any MIME epilogue, rather than accepting an early transport EOF after a
  valid MIME closing marker. The additional length checking uses bounded
  reads rather than copying the entire upload.
- The server now parses complete header values without removing quotes or
  dropping trailing content. Invalid Content-Length values such as
  `"3"junk`, embedded control characters, whitespace before the colon, and
  obsolete folded headers are rejected. Legal leading/trailing whitespace
  and quoted header values are preserved appropriately.
- Multipart closing markers can cross the parser's 65,536-byte buffer
  boundary. The parser also accepts valid closing padding, an omitted final
  CRLF, and an epilogue, while rejecting garbage on the closing line. See
  [RFC 2046, section 5.1.1](https://www.rfc-editor.org/rfc/rfc2046.html#section-5.1.1).

The framing checks follow [RFC 9112, section 6.3](https://www.rfc-editor.org/rfc/rfc9112.html#section-6.3).
The additional prohibition on 205 content is specified in
[RFC 9110, section 15.3.6](https://www.rfc-editor.org/rfc/rfc9110.html#section-15.3.6).
Existing tests that omitted the final empty header line were corrected to
send complete requests.

## Furnace fixes

- `get-state` returned expired database rows until the periodic cleanup
  deleted them. Lookup now checks the deadline. This applies to sessions,
  conversations, asides, and login permits; the timer still removes stale
  rows from storage.
- `get-permit-uid` renewed login permits only in memory. It now persists
  renewal after checking expiry and session ownership. An invalid session
  cannot renew a permit.
- `add-user` inverted the result of `new-user`, throwing after successful
  insertion and silently accepting duplicates. The condition is corrected.
- `claim-ticket` accepted absent or empty tickets when the stored ticket
  was empty. The provider now rejects both cases. The current recovery web
  action already requires a nonempty ticket, so the provider defect alone
  did not demonstrate a bypass through that action.
- `check-login` attempted password verification even when lookup returned
  no user, causing an exception. Unknown users now fail authentication.
- Deactivated users could pass password checking and be installed as the
  logged-in user through an existing permit. Both paths now reject them.
  `<protected>` already checked deactivation, but responders using
  `logged-in?` directly did not have that protection.
- Malformed Basic authentication data could throw during realm dispatch.
  It now fails authentication, producing 401 through a protected responder.
  The scheme name is matched without case sensitivity.
- Four debug annotations serialized user objects, responses, or saved
  submissions. They now record the call without its arguments. This
  avoids recording password hashes, recovery tickets, cookies, or saved
  form values through those annotations.

Session deadlines retain the existing policy of renewal on creation or
variable changes; merely reading a session does not renew it. The session
documentation now states that policy explicitly. Login permit renewal is
separate from the owning session's deadline.

## Verification

- The full `http` and `mime.multipart` test trees, including localhost
  integration tests and multipart buffer-boundary regressions.
- The full `furnace` test tree, including new SQLite permit tests, provider
  tests, deactivation tests, captured authentication logging, and malformed
  Basic authentication dispatch.
- A separate localhost socket harness: intact 70,000-byte plain and
  URL-encoded payloads; 18 multipart boundary/tail cases; 85 malformed
  requests returning 400; HEAD and 304 without a body;
  descriptors stable at 20 before and after the requests.
- Before-fix reproducers confirmed the HTTP truncation and parsing defects,
  expired permit acceptance, missing persisted renewal, reversed user
  insertion checks, and empty-ticket acceptance.

Commands:

```sh
./factor -no-user-init -run=tools.test http
./factor -no-user-init -run=tools.test mime.multipart
./factor -no-user-init -run=tools.test furnace
python3 /tmp/factor-http-audit-wire.py
```

The strict request-line parser is defined in `http.server.requests`, so
it is loaded with the server even when the saved image contains an older
compiled `http.parsers` vocabulary.

This is a targeted audit, not a claim of complete HTTP conformance or an
exhaustive security review. The running website was not restarted by this
audit. Existing sensitive log records are not rewritten by these changes.
