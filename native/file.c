#include "factor.h"

void primitive_open_file(void)
{
	bool write = untag_boolean(env.dt);
	bool read = untag_boolean(dpop());
	char* path = to_c_string(untag_string(dpop()));
	int mode;
	int fd;

	if(read && write)
		mode = O_RDWR | O_CREAT;
	else if(read)
		mode = O_RDONLY;
	else if(write)
		mode = O_WRONLY | O_CREAT | O_TRUNC;

	fd = open(path,mode);
	env.dt = handle(HANDLE_FD,fd);
}
