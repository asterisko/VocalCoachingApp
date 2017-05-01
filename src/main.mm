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
    
    
//    settings.width = 1024;
//    settings.height = 768;
//    
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



//#include "ofMain.h"
//#include "ssApp.h"
//#include "MidiApp.h"
//#include "mainAppViewController.h"
//
////////////////////////////////////////////////////////////////////////////////////
//// Pointer to Main APP
////////////////////////////////////////////////////////////////////////////////////
//ssApp * myApp;  // creates the pointer to main APP
//
////////////////////////////////////////////////////////////////////////////////////
//// Main - Is here that the SS obj is created
////////////////////////////////////////////////////////////////////////////////////
//int main(){
//    
//    
//    bool bUseNative = true;
//    
//    if (bUseNative){
//        /**
//         *
//         *  Below is how you start using a native ios setup.
//         *
//         *  First a ofAppiPhoneWindow is created and added to ofSetupOpenGL()
//         *  Notice that no app is being sent to ofRunApp() - this happens later when we actually need the app.
//         *
//         *  One last thing that needs to be done is telling ofAppiPhoneWindow which AppDelegate to use.
//         *  This is a custom AppDelegate and inside it you can start coding your native iOS application.
//         *  The AppDelegate must extend ofxiPhoneAppDelegate.
//         *
//         **/
//        
//        ofAppiPhoneWindow *window = new ofAppiPhoneWindow();
//        ofSetupOpenGL(ofPtr<ofAppBaseWindow>(window), 1024,768, OF_FULLSCREEN);
//        window->startAppWithDelegate("mainAppDelegate");
//        
//    }
//    else {
//        /**
//         *
//         *  This is the normal way of running an app using ofxiPhone.
//         *  This code has been left in this example to show that ofxiPhone still works
//         *
//         **/
//        
//        ofSetupOpenGL(1024,768, OF_FULLSCREEN);			// <-------- setup the GL context
//        
//        // Creates a new SS APP obj
//        myApp = new ssApp();
//        ofRunApp(myApp);    // Run APP
//    }
//}
