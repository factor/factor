#include "factor.h"

void primitive_open_file(void)
{
	bool write = untag_boolean(dpop());
	bool read = untag_boolean(dpop());
	char* path = to_c_string(untag_string(dpop()));
	int mode;
	int fd;

	if(read && write)
		mode = O_RDWR | O_CREAT | O_NONBLOCK;
	else if(read)
		mode = O_RDONLY | O_NONBLOCK;
	else if(write)
		mode = O_WRONLY | O_CREAT | O_TRUNC | O_NONBLOCK;
	else
		mode = O_NONBLOCK;

	fd = open(path,mode);
	if(fd < 0)
		io_error(__FUNCTION__);

	dpush(port(fd));
}
