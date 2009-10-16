namespace factor
{

struct aging_space : old_space {
	aging_space(cell size, cell start) : old_space(size,start) {}
};

}
