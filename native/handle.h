typedef struct {
	CELL header;
	/* untagged */
	CELL type;
	/* untagged */
	CELL object;
} HANDLE;

#define HANDLE_C_STREAM 1
#define HANDLE_FD 2

HANDLE* untag_handle(CELL type, CELL tagged);
CELL handle(CELL type, CELL object);
void primitive_handlep(void);
