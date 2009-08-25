#include "master.hpp"

int main(int argc, char **argv)
{
	#ifdef FACTOR_MULTITHREADED
	  factor::THREADHANDLE thread = factor::start_standalone_factor_in_new_thread(argc,argv);
	  pthread_join(thread,NULL);
    #else
	  factor::start_standalone_factor(argc,argv);
	#endif
	return 0;
}
