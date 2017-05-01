# AUDIOOPS LIB ###############################################################

INCLUDEPATH +=	$$(SVN_STATIC)/_include/audioops

win32-msvc2010{


	#AudioOps
	CONFIG(debug, debug|release):QMAKE_LIBDIR += $$(SVN_STATIC)/_lib/debug/audioops
	CONFIG(release, debug|release):QMAKE_LIBDIR += $$(SVN_STATIC)/_lib/release
	
	LIBS +=		audioops.lib
}

