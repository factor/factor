typedef struct _F_COMPILED_FRAME {
	struct _F_COMPILED_FRAME *previous;
	CELL return_address;
} F_COMPILED_FRAME;
