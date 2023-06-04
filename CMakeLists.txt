set(CMAKE_VERBOSE_MAKEFILE ON)
cmake_minimum_required(VERSION 3.16.3)
project(gRPC-Concepts)
set(CMAKE_CXX_STANDARD 17)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

include(grpc.cmake)

if(MSVC)
  add_compile_options(/W4 /WX)
else()
  add_compile_options(
    -Wall -Wextra -Wpedantic -Werror
    $<$<CONFIG:RELEASE>:-Ofast>
    $<$<CONFIG:DEBUG>:-O0>
    $<$<CONFIG:DEBUG>:-ggdb3>
  )
endif()


#find_package(Boost REQUIRED)
#include_directories(${Boost_INCLUDE_DIRS})

#include_directories(src)
#set("${CMAKE_PROJECT_NAME}_SRC"
#  main.cpp
#  src/Foo.cpp
#)
#add_executable(${CMAKE_PROJECT_NAME} ${${CMAKE_PROJECT_NAME}_SRC})
#target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Boost::headers)
