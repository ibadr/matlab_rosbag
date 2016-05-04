<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc/generate-toc again -->
**Table of Contents**

- [Overview](#overview)
- [Using ROS Indigo](#using-ros-indigo)

<!-- markdown-toc end -->

# Overview

In order to compile rosbag_wrapper into a mex function so that it can be used on a machine without ROS we need to statically compile all of the libraries that the C++ ROS bag API depends on.  ~~To make things harder, [mex files are shared object files](http://www.mathworks.com/help/matlab/matlab_external/troubleshooting-mex-files.html#bsscx2j-1) and so each statically linked library must have been compiled with the -fPIC flag.  See [this page](http://www.gentoo.org/proj/en/base/amd64/howtos/index.xml?part=1&chap=3) for a description of -fPIC.~~ (This issue is not very relevant to Windows. Just make sure to compile everything as a static library and link against [multithreaded static c runtime](https://msdn.microsoft.com/en-us/library/2kzt1wy3.aspx).)

Even if you only want to compile code for your machine, Matlab comes with its own version of several libraries used by ROS -- most notably Boost -- and these versions may be incompatible with your system version.  So, you'll either need to statically compile boost, or compile and link against the version that Matlab uses.

Compiling the needed ROS libraries on Windows is very tricky, and static compilation involved the discovery of [some issues](https://github.com/ros/console_bridge/pull/40). You will need the [<tt>win_ros</tt>](https://github.com/ibadr/win_ros) framework to help you in this process.

# Using ROS Indigo
You'll need to do several things in order.  First, make the workspace:

    set MAT_WS=C:\PATH\TO\WS
    mkdir %MAT_W%
    cd %MAT_WS%

All directions from here on out assume that the MAT_WS environment variable in Windows refers to the ROS workspace.

## [Boost 1.47](https://sourceforge.net/projects/boost/files/boost/1.47.0/boost_1_47_0.zip/download)
Download and unpack verison 1.47 of Boost and go to that directory using the Windows command prompt, then activate the [Visual Studio Build tools](https://msdn.microsoft.com/en-us/library/x4d2c09s.aspx) by running ``vcvarsall.bat``. This environment is assumed to be used througout the build process. Afterwards, compile boost

    > bootstrap.bat
    > b2 --build-dir=build64 --layout=versioned --build-type=complete --prefix=%MAT_WS%\install architecture=x86 address-model=64 install

To compile things with multiple processors, add the flag <tt>-jNUM_PROCESSORS</tt>

## [bz2](https://github.com/philr/bzip2-windows)

Download and unpack [64-bit version of BZ2](https://github.com/philr/bzip2-windows/releases/download/v1.0.6/bzip2-dev-1.0.6-win-x64.zip), go to that directory, and manually copy <tt>libbz2-static.lib</tt> and <tt>bzlib.h</tt>

    copy .\libbz2-static.lib %MAT_WS%\install\lib\bz2.lib
    copy .\bzlib.h %MAT_WS%\install\include

## [Console Bridge](https://github.com/ros/console_bridge)

Make sure to apply the fix in [here](https://github.com/ros/console_bridge/pull/40), if not already applied.

    git clone git://github.com/ros/console_bridge.git
    mkdir console_bridge\build
    cd console_bridge\build
    cmake .. -DBUILD_SHARED_LIBS=false -DCMAKE_BUILD_TYPE=Release -DBoost_NO_SYSTEM_PATHS=ON -DBOOST_ROOT=%MAT_WS%\install -DCMAKE_INSTALL_PREFIX=%MAT_WS%\install -G"NMake Makefiles"
    nmake install

## [LZ4](https://github.com/Cyan4973/lz4)
Download and unpack LZ4, go to that directory:

    mkdir lz4\build
    cd lz4\build
    cmake ..\cmake_unofficial -DBUILD_LIBS=true -DBUILD_TOOLS=false -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%MAT_WS%\install -G"NMake Makefiles"
    nmake install

## ROS ##

Compiling and installing the needed ROS packages on Windows involves a lot of manual work. More details on the needed steps will be posted [here](https://github.com/ibadr/win_ros) once a good level of automation is reached. The required packages are

    catkin
    roscpp_core
    roscpp_storage
    roslz4
    tf2
    tf2_msgs
    std_msgs
    actionlib_msgs
    geometry_msgs
    message_generation
    genmsg
    gencpp
    
In roslz4, it was necessary to ``#undef min`` in <tt>lz4s.c</tt> because ``min`` is a predefined macro under Windows. It was also necessary to remove the gcc-specifiec compiler flags from the <tt>CMakeLists.txt</tt> file.

[This fix](https://github.com/ros/console_bridge/pull/40) was necessary to be applied to the <tt>CMakeLists.txt</tt> files in <tt>rosbag_storage</tt>, <tt>cpp_common</tt>, and <tt>tf2</tt> packages.

Lastly, it was necessary to ``#undef NO_ERROR`` in the generated header file <tt>TF2Error.h</tt> from <tt>tf2_msgs</tt>.
    

## matlab_rosbag
Now use the <tt>mex_windows_compile.m</tt> MATLAB script

    mex_windows_compile

