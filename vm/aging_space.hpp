namespace factor
{

struct aging_space : old_space {
	aging_space(cell size, cell start) : old_space(size,start) {}

	bool is_nursery_p() { return false; }
	bool is_aging_p()   { return true; }
	bool is_tenured_p() { return false; }
};

}
