/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "ISSideBar.j"
@import "ISToolBar.j"
@import "ISAccountView.j"
@import "ISRepositoriesController.j"
@import "ISSourceListDataView.j"
@import "ISRepository.j"
@import "ISSortBar.j"
@import "ISIssuesController.j"
@import "CPWindow+animations.j"
@import "ISGithubAPIController.j"
@import "ISWindow.j"
@import "ISIssueDataView.j"
@import "ISModel.j"
@import "ISLoadingIndicator.j"
@import "LPMultiLineTextField.j"
@import "ISNewIssueWindowController.j"
@import "ISNewLabelWindowController.j"
@import "ISLabel.j"
@import "ISIssue.j"
@import "CPDate+extentions.j"

@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow;
    @outlet ISToolbar   toolbar @accessors(readonly);
    @outlet ISSideBar   sidebar;
    @outlet CPView      mainContentView;
    @outlet CPSplitView verticalSplitView;

    @outlet ISRepositoriesController reposController @accessors(readonly);
    @outlet ISModel     model @accessors;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [CPMenu setMenuBarVisible:NO];

    // try to login
    var defaults = [CPUserDefaults standardUserDefaults],
        user = [defaults objectForKey:"username"],
        pass = [defaults objectForKey:"password"],
        apicontroller = [ISGithubAPIController sharedController];

    if (user && pass)
    {
        [apicontroller setUsername:user];
        [apicontroller setPassword:pass];
        [apicontroller authenticateWithCallback:nil];
    }

    // FIX ME: parse the url arguments

    // Load any saved settings.
    [model load];
}

- (void)awakeFromCib
{
    // FIX ME: Xcode 4 wont let me do this... wtfbbq
    [mainContentView setAutoresizingMask:CPViewWidthSizable];


    if ([CPPlatform isBrowser])
        // In this case, we want the window from Cib to become our full browser window
        [theWindow setFullPlatformWindow:YES];
    else
    {
        // FIX ME: make this a sexy ISWindow style window
        var contentView = [theWindow contentView];
        theWindow = [[ISWindow alloc] initWithContentRect:CGRectMake(50, 50, 1000, 670) styleMask:nil];

        [contentView setFrame:CGRectMake(15,45,920,640)];

        [[theWindow contentView] addSubview:contentView];
        [theWindow orderFront:self];
    }


    [mainContentView setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("MainContentTexture.png", 164, 141)]];

    // we want to know when the source list changes size so we can update the toolbar tabs
    [sidebar setPostsFrameChangedNotifications:YES];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceListDidResize:) name:CPViewFrameDidChangeNotification object:sidebar];

    // Special split view styling.
    // FIX ME: get the rbga values here
    [verticalSplitView setValue:[CPColor colorWithHexString:"80878d"] forThemeAttribute:"pane-divider-color"];

    // To the right of the split view there is a 1px 0.25 alpha white line, but we can't make it part of the splitter
    // itself because it actually overlaps the lines and widgets on the right side. Instead, make a transparent
    // overlay view.
    var rightOfSplitterWhitenessView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1, [mainContentView bounds].size.height)];
    [rightOfSplitterWhitenessView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
    [rightOfSplitterWhitenessView setBackgroundColor:[CPColor colorWithCSSString:"rgba(255, 255, 255, 0.267)"]];
    // XXX This view must always be above all other views in the main content area.
    [mainContentView addSubview:rightOfSplitterWhitenessView];
}


- (@action)newRepo:(id)aSender
{
    [[ISNewRepoWindow sharedWindow] showWindow:aSender];
}

- (@action)newIssue:(id)sender
{
    var newIssueWindow = [[ISNewIssueWindowController alloc] initWithWindowCibName:"NewIssueWindow"];
    [newIssueWindow setRepos:[reposController arrangedObjects]];
    [newIssueWindow showWindow:sender];
    [newIssueWindow selectRepo:[reposController selectedObjects][0]];
}

// Main splitview delegates
- (void)sourceListDidResize:(CPNotification)aNote
{
    // As the splitview resizes
    // we need to reposition the tab view thingy at the top...

    // plus a couple to take the splitview divider into account...
    var point = [[aNote object] frameSize].width + 2;
    [toolbar splitViewMovedTo:point];
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

#pragma mark hello world

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
