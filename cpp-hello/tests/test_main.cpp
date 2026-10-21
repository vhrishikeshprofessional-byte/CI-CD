#include <cassert>
#include <iostream>
#include "greeting.h"

int main() {
    assert(greeting() == "Hello from C++!");
    std::cout << "All C++ assertions passed successfully.\n";
    return 0;
}
