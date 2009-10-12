namespace factor
{

struct tenured_space : old_space {
	tenured_space(cell size, cell start) : old_space(size,start) {}

	bool is_nursery_p() { return false; }
	bool is_aging_p()   { return false; }
	bool is_tenured_p() { return true; }
};

}
