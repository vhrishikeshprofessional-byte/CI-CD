cmake_minimum_required(VERSION 3.20)
project(cpp_hello LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Greeting core library
add_library(greeting STATIC src/greeting.cpp)
target_include_directories(greeting PUBLIC src)
if(MSVC)
    target_compile_options(greeting PRIVATE /W4 /WX)
else()
    target_compile_options(greeting PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

# CLI Executable
add_executable(cpp-hello src/main.cpp)
target_link_libraries(cpp-hello PRIVATE greeting)
if(MSVC)
    target_compile_options(cpp-hello PRIVATE /W4 /WX)
else()
    target_compile_options(cpp-hello PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

# Unit Test Executable
enable_testing()
add_executable(cpp-tests tests/test_main.cpp)
target_link_libraries(cpp-tests PRIVATE greeting)
if(MSVC)
    target_compile_options(cpp-tests PRIVATE /W4 /WX)
else()
    target_compile_options(cpp-tests PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

add_test(NAME greeting_test COMMAND cpp-tests)
