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
@import "ISSourceListDataView.j"
@import "ISRepository.j"
@import "ISSortBar.j"


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


// Main splitview delegates
- (void)splitViewDidResizeSubviews:(CPSplitView)aSplitView
{
    // As the splitview resizes
    // we need to reposition the tab view thingy at the top...
}

- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)subviewIndex
{
    return 210;
}

- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)subviewIndex
{
    return 300;
}
@end


/*!
    FIX ME:
    Make this more awesome
*/
@implementation ISScroller : CPScroller

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        var scrollerColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("scroller_top.png", 11, 6),
            resourcesImage("scroller_mid.png", 11, 9),
            resourcesImage("scroller_bot.png", 11, 6)
        ] isVertical:YES]];

        var bgColor = [CPColor clearColor];

        [self setValue:scrollerColor forThemeAttribute:"knob-color"];
        [self setValue:bgColor forThemeAttribute:"knob-slot-color"];
        [self setValue:bgColor forThemeAttribute:"increment-line-color"];
        [self setValue:bgColor forThemeAttribute:"decrement-line-color"];
        [self setValue:CGSizeMake(11,5) forThemeAttribute:"decrement-line-size"];
        [self setValue:CGSizeMake(11,5) forThemeAttribute:"increment-line-size"];
    }

    return self;
}

@end


/*!
    We're going to define a nice global helper function to load images from the main bundle.
*/
resourcesImage = function(path, width, height)
{
    return [[CPImage alloc] initByReferencingFile:[[CPBundle mainBundle] pathForResource:path] size:CGSizeMake(width, height)];
}