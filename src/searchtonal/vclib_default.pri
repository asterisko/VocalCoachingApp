TEMPLATE =		lib

CONFIG += static
DEPENDPATH += 	src
INCLUDEPATH += 	src \
				$$(SVN_STATIC)/_include 

QMAKE_LIBDIR += $$(QTDIR)/lib
INCLUDEPATH += $$(QTDIR)/include
				
QMAKE_LFLAGS +=/MACHINE:X86

CONFIG(debug, debug|release) { 
	UI_DIR = 		_tmp/debug
	MOC_DIR = 		_tmp/debug
	OBJECTS_DIR = 	        _tmp/debug
	RCC_DIR +=		_tmp/debug
	QMAKE_LIBDIR += $$(SVN_STATIC)/_lib/debug
	DESTDIR =		_out/debug
	DEFINES += 		_DEBUG
	DEFINES -= 		NDEBUG
	CONFIG += 		console	
}
CONFIG(release, debug|release) {
	UI_DIR = 		_tmp/release
	MOC_DIR = 		_tmp/release
	OBJECTS_DIR = 	        _tmp/release
	RCC_DIR +=		_tmp/release
	QMAKE_LIBDIR += $$(SVN_STATIC)/_lib/release
	DESTDIR =		_out/release
	DEFINES += 		NDEBUG
	DEFINES -= 		_DEBUG
	QMAKE_CXXFLAGS_RELEASE += -GL
	QMAKE_LFLAGS_RELEASE += /ltcg	
}