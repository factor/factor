/* relocation base of currently loaded image */
CELL relocation_base;

/* used as a temporary variable while relocating */
CELL relocating;

void fixup(CELL* cell);
void relocate_object();
void relocate_next(void);
void relocate(CELL r);
