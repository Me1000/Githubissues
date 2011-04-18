/*
 * AppController.j
 * GithubIssues
 *
 * Created by You on April 14, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "ISSideBar.j"
@import "ISToolBar.j"
@import "ISAccountView.j"
@import "ISRepositoriesController.j"



@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow;
    @outlet ISToolbar   toolbar;
    @outlet ISSideBar   sidebar;
    @outlet CPView      mainContentView;

}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [CPMenu setMenuBarVisible:NO];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.


    // FIX ME: Xcode 4 wont let me do this... wtfbbq
    [mainContentView setAutoresizingMask:CPViewWidthSizable];
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullPlatformWindow:YES];

    [mainContentView setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("MainContentTexture.png", 164, 141)]];
}

@end


/*!
    We're going to define a nice global helper function to load images from the main bundle. 
*/
resourcesImage = function(path, width, height)
{
    return [[CPImage alloc] initByReferencingFile:[[CPBundle mainBundle] pathForResource:path] size:CGSizeMake(width, height)];
}