set(gRPC_INSTALL                       OFF CACHE BOOL "Do not install gRPC globally")
set(gRPC_BUILD_TESTS                   OFF CACHE BOOL "Skip building gRPC tests")
set(gRPC_BUILD_CODEGEN                 ON  CACHE BOOL "Enable building gRPC codegen")
set(gRPC_BUILD_CSHARP_EXT              OFF CACHE BOOL "Skip building gRPC C# extensions")
set(gRPC_BUILD_GRPC_CPP_PLUGIN         ON  CACHE BOOL "Enable building gRPC C++ plugin")
set(gRPC_BUILD_GRPC_CSHARP_PLUGIN      OFF CACHE BOOL "Skip building gRPC C# plugin")
set(gRPC_BUILD_GRPC_NODE_PLUGIN        OFF CACHE BOOL "Skip building gRPC NodeJS plugin")
set(gRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN OFF CACHE BOOL "Skip building gRPC Objective-C plugin")
set(gRPC_BUILD_GRPC_PHP_PLUGIN         OFF CACHE BOOL "Skip building gRPC PHP plugin")
set(gRPC_BUILD_GRPC_PYTHON_PLUGIN      OFF CACHE BOOL "Skip building gRPC Python plugin")
set(gRPC_BUILD_GRPC_RUBY_PLUGIN        OFF CACHE BOOL "Skip building gRPC Ruby plugin")
set(ABSL_PROPAGATE_CXX_STD             ON  CACHE BOOL "Use CMake C++ standard meta features (e.g. cxx_std_14) that propagate to targets that link to Abseil")
set(ABSL_ENABLE_INSTALL                ON  CACHE BOOL "Enable abseil install in order to force generation of export targets, otherwise cmake fails")

set(gRPC_ABSL_PROVIDER     "module" CACHE STRING "Build dependency from source rather than relying on a system package")
set(gRPC_CARES_PROVIDER    "module" CACHE STRING "Build dependency from source rather than relying on a system package")
set(gRPC_PROTOBUF_PROVIDER "module" CACHE STRING "Build dependency from source rather than relying on a system package")
set(gRPC_RE2_PROVIDER      "module" CACHE STRING "Build dependency from source rather than relying on a system package")
set(gRPC_SSL_PROVIDER      "module" CACHE STRING "Build dependency from source rather than relying on a system package")
set(gRPC_ZLIB_PROVIDER     "module" CACHE STRING "Build dependency from source rather than relying on a system package")

add_subdirectory(external/grpc)

function(protobuf_generate_grpc_cpp SRCS HDRS)
  if(NOT ARGN)
    message(SEND_ERROR "Error: protobuf_generate_grpc_cpp() called without any proto files")
    return()
  endif()

  if(PROTOBUF_GENERATE_CPP_APPEND_PATH) # This variable is common for all types of output.
    # Create an include path for each file specified
    foreach(FIL ${ARGN})
      get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
      get_filename_component(ABS_PATH ${ABS_FIL} PATH)
      list(FIND _protobuf_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _protobuf_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  else()
    set(_protobuf_include_path -I ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  if(DEFINED PROTOBUF_IMPORT_DIRS)
    foreach(DIR ${Protobuf_IMPORT_DIRS})
      get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
      list(FIND _protobuf_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _protobuf_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  endif()

  set(${SRCS})
  set(${HDRS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)

    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.grpc.pb.cc")
    list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.grpc.pb.h")

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.grpc.pb.cc"
             "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.grpc.pb.h"
      COMMAND  $<TARGET_FILE:protoc>
      ARGS --grpc_out=${CMAKE_CURRENT_BINARY_DIR}
           --cpp_out=${CMAKE_CURRENT_BINARY_DIR}
           --plugin=protoc-gen-grpc=$<TARGET_FILE:grpc_cpp_plugin>
           ${_protobuf_include_path} ${ABS_FIL}
      DEPENDS ${ABS_FIL} ${_gRPC_PROTOBUF_PROTOC_EXECUTABLE}
      COMMENT "Running gRPC C++ protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()
