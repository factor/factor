typedef struct {
	CELL header;
	CELL type;
	CELL object;
	CELL buffer; /* tagged */
	CELL buf_fill;
	CELL buf_pos;
} HANDLE;

#define HANDLE_FD 1

HANDLE* untag_handle(CELL type, CELL tagged);
CELL handle(CELL type, CELL object);
void primitive_handlep(void);
void fixup_handle(HANDLE* handle);
void collect_handle(HANDLE* handle);
