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

set(SRC_DIR src)
set(PROTO_DIR ${SRC_DIR}/grpc_concepts/proto)

message(STATUS "Globbing ${PROJECT_NAME} proto files...")
file(GLOB_RECURSE PROTO_SRCS LIST_DIRECTORIES false CONFIGURE_DEPENDS ${PROTO_DIR}/*.proto)
set(PROTOBUF_GENERATE_CPP_APPEND_PATH ON)
protobuf_generate_grpc_cpp(GENERATED_PROTO_SRCS GENERATED_PROTO_HDRS ${PROTO_SRCS})

add_executable(
  test
  src/grpc_concepts/sync/test.cpp
  ${GENERATED_PROTO_SRCS}
  ${GENERATED_PROTO_HDRS}
)
target_link_libraries(test grpc grpc++)
#find_package(Boost REQUIRED)
#include_directories(${Boost_INCLUDE_DIRS})

#include_directories(src)
#set("${CMAKE_PROJECT_NAME}_SRC"
#  main.cpp
#  src/Foo.cpp
#)
#add_executable(${CMAKE_PROJECT_NAME} ${${CMAKE_PROJECT_NAME}_SRC})
#target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Boost::headers)
