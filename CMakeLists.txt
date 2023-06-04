set(CMAKE_VERBOSE_MAKEFILE OFF)
cmake_minimum_required(VERSION 3.16.3)
project(gRPC-Concepts C CXX)
set(CMAKE_CXX_STANDARD 17)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

include(grpc.cmake)

set(SRC_DIR src)
set(PROTO_DIR ${SRC_DIR}/grpc_concepts/proto)
file(GLOB_RECURSE SRC_FILES LIST_DIRECTORIES false CONFIGURE_DEPENDS ${SRC_DIR}/*.cpp)
file(GLOB_RECURSE HDR_FILES LIST_DIRECTORIES false CONFIGURE_DEPENDS ${SRC_DIR}/*.h)
set_property(SOURCE ${SRC_FILES} PROPERTY COMPILE_FLAGS -Wall -Wextra -Wpedantic -Werror $<$<CONFIG:RELEASE>:-Ofast> $<$<CONFIG:DEBUG>:-O0> $<$<CONFIG:DEBUG>:-ggdb3>)
set_property(SOURCE ${HDR_FILES} PROPERTY COMPILE_FLAGS -Wall -Wextra -Wpedantic -Werror $<$<CONFIG:RELEASE>:-Ofast> $<$<CONFIG:DEBUG>:-O0> $<$<CONFIG:DEBUG>:-ggdb3>)

message(STATUS "Globbing ${PROJECT_NAME} proto files...")
file(GLOB_RECURSE PROTO_SRCS LIST_DIRECTORIES false CONFIGURE_DEPENDS ${PROTO_DIR}/*.proto)
set(PROTOBUF_GENERATE_CPP_APPEND_PATH ON)
protobuf_generate_grpc_cpp(GENERATED_PROTO_SRCS GENERATED_PROTO_HDRS ${PROTO_SRCS})
set_property(SOURCE ${GENERATED_PROTO_SRCS} PROPERTY COMPILE_FLAGS -Wno-error -Wno-pedantic)
set_property(SOURCE ${GENERATED_PROTO_HDRS} PROPERTY COMPILE_FLAGS -Wno-error -Wno-pedantic)

add_executable(
  ${PROJECT_NAME}
  ${SRC_FILES}
  ${HDR_FILES}
  ${GENERATED_PROTO_SRCS}
  ${GENERATED_PROTO_HDRS}
)
target_include_directories(${PROJECT_NAME} PUBLIC src)
target_link_libraries(${PROJECT_NAME} grpc grpc++)
