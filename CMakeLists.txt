cmake_minimum_required(VERSION 2.8.12)
project(pinocchio)

find_package(catkin REQUIRED COMPONENTS eigenpy)
find_package(Eigen3 REQUIRED)
find_package(Boost REQUIRED COMPONENTS system)

include(ExternalProject)

add_definitions(-Wno-conversions -Wno-deprecated)

ExternalProject_Add(pinocchio_src
  GIT_REPOSITORY "https://github.com/stack-of-tasks/pinocchio.git"
  GIT_TAG "v2.1.3"

  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  TEST_COMMAND ""
  CMAKE_ARGS -DBUILD_UNIT_TESTS:BOOL=OFF -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_BINARY_DIR}/install -Deigenpy_FOUND=${eigenpy_FOUND} -Deigenpy_INCLUDE_DIRS=${eigenpy_INCLUDE_DIRS} -Deigenpy_LIBRARIES=${eigenpy_LIBRARIES} -DEIGEN3_INCLUDE_DIR=${EIGEN3_INCLUDE_DIR} -DBUILD_PYTHON_INTERFACE:BOOL=ON #-DPYTHON_DEB_LAYOUT:BOOL=${SETUPTOOLS_DEB_LAYOUT} - we copy from site-packages
)
ExternalProject_Add_Step(pinocchio_src CopyToDevel
  COMMENT "Copying to devel"
  COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/install/lib/libpinocchio.so ${CATKIN_DEVEL_PREFIX}/lib/
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CATKIN_DEVEL_PREFIX}/lib/python2.7/dist-packages/
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${PROJECT_BINARY_DIR}/install/lib/python2.7/site-packages/pinocchio/ ${CATKIN_DEVEL_PREFIX}/lib/python2.7/dist-packages/pinocchio/
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${PROJECT_BINARY_DIR}/install/include/${PROJECT_NAME}/ ${CATKIN_DEVEL_PREFIX}/include/${PROJECT_NAME}/
  DEPENDEES install
)

include(cmake/pinocchio.cmake)

if(IS_DIRECTORY ${CMAKE_INSTALL_PREFIX})
  message(STATUS "Compiling for install workspace (${CMAKE_INSTALL_PREFIX})")
  catkin_package(
    INCLUDE_DIRS include/${PROJECT_NAME} ${EIGEN3_INCLUDE_DIR}
    LIBRARIES ${PYTHON_LIBRARIES} pinocchio
    DEPENDS urdfdom urdfdom_headers Boost
    CFG_EXTRAS pinocchio.cmake
    # SKIP_PKG_CONFIG_GENERATION
  )
else()
  message(STATUS "Compiling for devel workspace")
  file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include/${PROJECT_NAME})
  catkin_package(
    INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include ${EIGEN3_INCLUDE_DIR}
    LIBRARIES ${PYTHON_LIBRARIES} pinocchio
    DEPENDS urdfdom urdfdom_headers Boost
    CFG_EXTRAS pinocchio.cmake
    # SKIP_PKG_CONFIG_GENERATION
  )
endif()

install(
  DIRECTORY ${CATKIN_DEVEL_PREFIX}/include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)
install(
  FILES ${CATKIN_DEVEL_PREFIX}/lib/libpinocchio.so
  DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
)
install(
  DIRECTORY ${CATKIN_DEVEL_PREFIX}/lib/python2.7/dist-packages/pinocchio/
  DESTINATION ${CATKIN_PACKAGE_PYTHON_DESTINATION}
)
