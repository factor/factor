/* Copyright (C) 2026 Factor contributors.
 * See https://factorcode.org/license.txt for BSD license. */
typedef enum ImportColor {
    IMPORT_RED = 1,
    IMPORT_GREEN = (1 << 3),
    IMPORT_BLUE = IMPORT_GREEN + 1
} ImportColor;

typedef struct ImportPoint {
    int x;
    int y;
} ImportPoint;

int import_sum(ImportPoint *point, int count);
static inline int import_inline(int value) { return value + 1; }
