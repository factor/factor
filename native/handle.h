typedef struct {
	CELL header;
	/* untagged */
	CELL object;
} HANDLE;

HANDLE* untag_handle(CELL tagged);
CELL handle(CELL object);
void primitive_handlep(void);
