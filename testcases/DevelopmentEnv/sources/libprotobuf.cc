#include <iostream>
#include "libprotobuf.pb.h"
int main(int argc, char** argv) {
	tutorial::Person person1;
	person1.set_name("lz");
	std::cout << person1.name() << std::endl;
        std::cout << "hello world" << std::endl;
}
