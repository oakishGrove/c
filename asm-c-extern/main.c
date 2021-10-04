//
// Created by oak on 2021-10-02.
//

#include <stdio.h>

int staticTest() {
	static int var = 0;
	++var;
	return var;
}

int main(int argc, char** argv) {
    for (int i = 0; i < argc; ++i) {
        puts(argv[i]);
    }
    return 0;
}
