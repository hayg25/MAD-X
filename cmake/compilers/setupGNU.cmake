
###
#
# This file sets up specific flags for the GNU compiler
#
###

if (CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    # General:
    set(CMAKE_Fortran_FLAGS " -fno-range-check -fno-f2c -cpp ") # remove -g -O2 from main list
    execute_process(COMMAND ${CMAKE_Fortran_COMPILER} --version OUTPUT_VARIABLE CMAKE_Fortran_COMPILER_VERSION)
    string(REGEX MATCH "[3-9].[0-9].[0-9]" CMAKE_Fortran_COMPILER_VERSION ${CMAKE_Fortran_COMPILER_VERSION})
    if(${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 4.3.9)
        add_definitions(-D_GFORTRAN)
    endif()
    # Release flags:
    # ON APPLE machines and on 32bit Linux systems, -O2 seems to be the highest optimization level possible
    # for file l_complex_taylor.f90
    if(APPLE OR IS32BIT)
        if (${CMAKE_Fortran_COMPILER_VERSION} VERSION_LESS 4.6)
          set(CMAKE_Fortran_FLAGS_RELEASE "-O1")
        endif()
    else()
        set(CMAKE_Fortran_FLAGS_RELEASE "-O4")
    endif()
    set(CMAKE_Fortran_FLAGS_RELEASE "-funroll-loops ${CMAKE_Fortran_FLAGS_RELEASE}")

    # Additional option dependent flags:
    if ( MADX_STATIC )
        set(CMAKE_Fortran_LINK_FLAGS   "${CMAKE_Fortran_LINK_FLAGS} -static ")
    endif ()
    if(IS32BIT)
        set (CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m32")
    endif()
    if(${CMAKE_Fortran_COMPILER_VERSION} VERSION_LESS 4.5) # argument -fcheck=bounds is not recognised..
       set(CMAKE_Fortran_FLAGS_DEBUG   " -Wall -fbounds-check ${CMAKE_Fortran_FLAGS_DEBUG}")
    else()
       set(CMAKE_Fortran_FLAGS_DEBUG   " -Wall -fcheck=bounds ${CMAKE_Fortran_FLAGS_DEBUG}")
    endif()
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98")
    if(WIN32)
      # MinGW automatically adds -ansi, so c++ code does not compile without this flag as well..
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -U__STRICT_ANSI__")
    endif()
endif()
