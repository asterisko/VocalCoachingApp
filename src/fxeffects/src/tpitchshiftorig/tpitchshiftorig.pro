# Default
include(/svn/_conf/vcapp_default.pri)
include(/svn/_conf/win32-msvc2005.pri)

TARGET = tpitchshiftorig

SOURCES += *.cpp \ 
           searchtonal/*.cpp
HEADERS += *.h \
           searchtonal/*.h

SOURCES += ../utils\iowave/*.cpp
HEADERS += ../utils\iowave/*.h