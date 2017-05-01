#GENERAL CONFIGURATION ###############################################################

include ($$(SVN_STATIC)/_conf/vclib_default.pri)
include ($$(SVN_STATIC)/_conf/win32-msvc2010.pri)

# WINDOW'S CONFIGURATION ###############################################################


#SPECIFIC CONFIGURATION #############################################################

TARGET = fxeffects


HEADERS += src/tpitchshiftorig/tpitchshiftorig.h src/tpitchshiftorig/searchtonal/window.h src/tpitchshiftorig/searchtonal/segment.h src/tpitchshiftorig/searchtonal/statseg.h .rc/tpitchshiftorig/searchtonal/transform.h \
           src/fpitchshift/fpitchshift.h

SOURCES += src/tpitchshiftorig/tpitchshiftorig.cpp src/tpitchshiftorig/searchtonal/window.cpp src/tpitchshiftorig/searchtonal/segment.cpp src/tpitchshiftorig/searchtonal/statseg.cpp src/tpitchshiftorig/searchtonal/transform.cpp \
           src/fpitchshift/fpitchshift.cpp