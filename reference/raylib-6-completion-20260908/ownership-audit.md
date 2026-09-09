# Raylib 6.0 ownership audit

Audited tag 6.0, commit dbc56a87da87d973a9c5baa4e7438a9d20121d28,
against the actual implementation as well as raylib.h. The mutable `char*`
return spelling alone does not establish ownership.

| Allocating API | Native result | Matching release | Factor convenience |
|---|---|---|---|
| LoadFileData | uchar* plus exact byte count | UnloadFileData | load-file-data-bytes |
| LoadFileText | char* | UnloadFileText | load-file-text |
| LoadUTF8 | char* | UnloadUTF8 | load-utf8 |
| EncodeDataBase64 | char*; count includes NUL | MemFree | encode-data-base64 |
| TextReplaceAlloc | char* | MemFree | text-replace-alloc |
| TextReplaceBetweenAlloc | char* | MemFree | text-replace-between-alloc |
| TextInsertAlloc | char* | MemFree | text-insert-alloc |
| LoadTextLines | char**, each line and outer array allocated | UnloadTextLines(pointer,count) | Existing pointer representation retained |

The six allocating text functions have explicit `-raw` words. Existing names
continue returning Factor strings, now copying before exception-safe release.
NULL remains `f`. Native pointer callers must use the matching raw API and
release exactly once. Binary LoadFileData cannot correctly retain its old
string-returning behavior: load-file-data now preserves the pointer and count,
and load-file-data-bytes provides the copying convenience.

GetTextBetween, TextReplace, TextReplaceBetween, TextInsert, TextJoin,
TextToUpper/Lower/Pascal/Snake/Camel, TextFormat, TextSubtext, TextRemoveSpaces,
CodepointToUTF8, and path/query string results use borrowed/static storage.
Keep their existing Factor string copies; do not free static results.
TextSplit also uses static storage; LoadTextLines does not.

TextCopy's destination and TextAppend's first argument must be writable raw
pointers. Factor strings only provide a temporary C encoding and are not valid
writable destinations. SaveFileText and replacement/insertion source strings
are const in the actual 6.0 header and implementation, so remain c-string.

LoadFileDataCallback and LoadFileTextCallback already return native pointer
types. rcore.c passes their returned allocations through, and the corresponding
unloaders always RL_FREE them. Documented that callbacks return MemAlloc-
compatible foreign allocations, never Factor-managed or static storage.

Already-correct ownership was retained for CompressData, DecompressData,
DecodeDataBase64 and ExportImageToMemory (MemFree), codepoint and glyph arrays,
image/wave/music resources, and FilePathList paths (their owning resource's
unloader). Static hash buffers must not be freed. DecodeDataBase64's input
conversion changes to c-string while its binary output remains uchar*.

Repository search excluding reference/** and root codex/** found no production
callers of the corrected APIs requiring migration. The existing ARRAY-SLOT
helpers explicitly call >c-ptr and continue accepting concrete struct pointer
fields. Destructor registrations now receive ownership-bearing pointers.

Implementation evidence: rtext.c lines1508–1547, 1737–2055, 2243–2276;
rcore.c lines1966–2028, 2116–2198, 3039+. The 6.0 checkout has no utils.c;
those functions now live in rcore.c. The stale upstream TextInsert free warning
contradicts its static buffer implementation and is not copied into our docs.
