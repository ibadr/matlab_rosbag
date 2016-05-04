INSTALL = input('Please enter full path to root directory: ','s');
LIB = [fullfile(INSTALL,'lib') filesep];
INCLUDE = fullfile(INSTALL,'include');
EigenINCLUDE = fullfile(INCLUDE,'eigen');
mexCommand = ['mex -O rosbag_wrapper.cpp parser.cpp ' ...
    LIB 'rosbag_storage.lib ' ...
    LIB 'roslz4.lib ' ...
    LIB 'lz4.lib ' ...
    LIB 'cpp_common.lib ' ...
    LIB 'rostime.lib ' ...
    LIB 'console_bridge.lib ' ...
    LIB 'tf2.lib ' ...
    LIB 'roscpp_serialization.lib ' ...
    LIB 'bz2.lib ' ...
    LIB 'libboost_date_time-vc100-mt-1_47.lib ' ...
    LIB 'libboost_regex-vc100-mt-1_47.lib ' ...
    LIB 'libboost_signals-vc100-mt-1_47.lib ' ...
    LIB 'libboost_system-vc100-mt-1_47.lib ' ...
    LIB 'libboost_thread-vc100-mt-1_47.lib ' ...
    '-I' INCLUDE ' ' ...
    '-I' EigenINCLUDE];
eval(mexCommand)
