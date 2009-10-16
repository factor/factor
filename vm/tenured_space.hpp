namespace factor
{

struct tenured_space : old_space {
	tenured_space(cell size, cell start) : old_space(size,start) {}
};

}
