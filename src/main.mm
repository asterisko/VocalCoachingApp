#include "ofMain.h"
#include "ssApp.h"
#include "MidiApp.h"
//#include "mainAppViewController.h"
#include "vcAppViewController.h" // 30_03


ssApp * myApp;  // creates the pointer to main APP


int main() {
    
    //  here are the most commonly used iOS window settings.
    //------------------------------------------------------
    ofiOSWindowSettings settings;
    settings.enableRetina = true; // enables retina resolution if the device supports it.
    settings.enableDepth = false; // enables depth buffer for 3d drawing.
    settings.enableAntiAliasing = true; // enables anti-aliasing which smooths out graphics on the screen.
    settings.numOfAntiAliasingSamples = 4; // number of samples used for anti-aliasing.
    settings.enableHardwareOrientation = true; // enables native view orientation.
    settings.enableHardwareOrientationAnimation = false; // enables native orientation changes to be animated.
    settings.glesVersion = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, etc.
    
//    settings.enableSetupScreen = true; // ANDRE orientation
//    settings.setupOrientation = OF_ORIENTATION_90_LEFT;
//    settings.windowMode = OF_FULLSCREEN;

    
    //ofAppiOSWindow *window = new ofAppiOSWindow();
    ofCreateWindow(settings);
    //window->startAppWithDelegate("mainAppDelegate");

    
    //ofAppiOSWindow::startAppWithDelegate("mainAppDelegate");
    ofAppiOSWindow::startAppWithDelegate("vcAppDelegate"); // 31_03
    
    
    //return ofRunApp(new mpApp);
    myApp = new ssApp;      //adic
    return ofRunApp(myApp); //adic
}
