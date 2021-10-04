//
// Created by oak on 2021-10-02.
//
#include <stdio.h>

int myStringLength(char* string, char delim) {
    int counter = 0;
    while(*string != delim || *string++ != '\0')
        ++counter;
    return counter;
}

void printUsage() {
    puts("2 params required");
    puts("<Program> <source-file> <destination-file>");
}