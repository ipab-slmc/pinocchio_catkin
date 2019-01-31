# catkin generates its own pkg-config files. These do not contain all the logic
# included in the original Pinocchio. As thus, we have to mirror the logic here
# as a configuration-step logic:

# force automatic escaping of preprocessor definitions
cmake_policy(PUSH)
cmake_policy(SET CMP0005 NEW)

# find_package(CppAD QUIET)
# if(CPPAD_FOUND)
#     # Mirror PKG_CONFIG_APPEND_CFLAGS("-DPINOCCHIO_WITH_CPPAD_SUPPORT")
#     add_compile_options(-DPINOCCHIO_WITH_CPPAD_SUPPORT)
#     message(FATAL_ERROR "CppAD logic not yet implemented")
#     # PKG_CONFIG_APPEND_CFLAGS("-DPINOCCHIO_CPPAD_REQUIRES_MATRIX_BASE_PLUGIN")
#     # PKG_CONFIG_APPEND_CFLAGS("-DPINOCCHIO_WITH_CPPADCG_SUPPORT")
# endif(CPPAD_FOUND)

# Special care of urdfdom version
find_package(PkgConfig)
pkg_search_module(URDFDOM urdfdom)
# find_package(urdfdom QUIET) # Does not export version :'(
if(URDFDOM_FOUND)
  if(${URDFDOM_VERSION} VERSION_LESS "0.3.0")
    add_definitions(-DPINOCCHIO_URDFDOM_COLLISION_WITH_GROUP_NAME)
  endif(${URDFDOM_VERSION} VERSION_LESS "0.3.0")

  # defines types from version 0.4.0
  if(NOT ${URDFDOM_VERSION} VERSION_LESS "0.4.0")
    add_definitions(-DPINOCCHIO_URDFDOM_TYPEDEF_SHARED_PTR)
  endif(NOT ${URDFDOM_VERSION} VERSION_LESS "0.4.0")
  
  # std::shared_ptr appears from version 1.0.0
  if(${URDFDOM_VERSION} VERSION_GREATER "0.4.2")
    add_definitions(-DPINOCCHIO_URDFDOM_USE_STD_SHARED_PTR)
  endif(${URDFDOM_VERSION} VERSION_GREATER "0.4.2")
endif(URDFDOM_FOUND)

cmake_policy(POP)
