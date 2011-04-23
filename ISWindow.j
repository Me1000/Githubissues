/*!
    Created by Randy Luecke April 22nd, 2011
    Copyright RCLConcepts, LLC. All right reserved

    used for the awesome translucent windows
*/

var WindowBackground = nil;

@implementation ISWindow : CPWindow

+ (void)initialize
{
    WindowBackground = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:[
        resourcesImage("windows/popoverwindow-0.png", 65, 53),
        resourcesImage("windows/popoverwindow-1.png", 17, 53),
        resourcesImage("windows/popoverwindow-2.png", 44, 53),

        resourcesImage("windows/popoverwindow-3.png", 65, 48),
        resourcesImage("windows/popoverwindow-4.png", 17, 48),
        resourcesImage("windows/popoverwindow-5.png", 44, 48),

        resourcesImage("windows/popoverwindow-6.png", 65, 62),
        resourcesImage("windows/popoverwindow-7.png", 17, 62),
        resourcesImage("windows/popoverwindow-8.png", 44, 62)
    ]]];
}

- (void)awakeFromCib
{
//    [self setStyleMask:CPBorderlessWindowMask];
    [[self contentView] setBackgroundColor:WindowBackground];
}

- (id)initWithContentRect:(CGRect)aRect
{
    self = [super initWithContentRect:aRect styleMask:CPBorderlessWindowMask];

    return self;
}

- (id)initWithContentRect:(CGRect)aRect styleMask:(unsigned)aMask
{
    self = [super initWithContentRect:aRect styleMask:0];

    [self setMovableByWindowBackground:YES];
    [[self contentView] setBackgroundColor:WindowBackground];

    return self;
}

@end

var SharedNewRepoWindow = nil;

@implementation ISNewRepoWindow : ISWindow
{
    @outlet CPTextField repoNameField;
    @outlet CPButton    submitButton;
    @outlet CPButton    cancelButton;
}

+ (id)sharedWindow
{
console.log([SharedNewRepoWindow frame]);
    return SharedNewRepoWindow;
}

- (void)awakeFromCib
{
[super awakeFromCib];
    SharedNewRepoWindow = self;

    var bezel = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("textfield-0.png", 18, 43),
        resourcesImage("textfield-1.png", 10, 43),
        resourcesImage("textfield-2.png", 18, 43)
    ] isVertical:NO]];

    [repoNameField setValue:bezel forThemeAttribute:"bezel-color"];

    [repoNameField setValue:bezel forThemeAttribute:"bezel-color"];
    [repoNameField setValue:CGInsetMake(0,0,0,0) forThemeAttribute:"bezel-inset"];
    [repoNameField setValue:CPCenterVerticalTextAlignment forThemeAttribute:"vertical-alignment"];
    [repoNameField setValue: CGInsetMake(2.0, 7.0, 5.0, 12.0) forThemeAttribute:"content-inset"];
    [repoNameField setValue: CGInsetMake(0.0, 7.0, 5.0, 12.0) forThemeAttribute:"content-inset" inState:CPThemeStateEditing|CPThemeStateBezeled];

}

- (@action)addRepo:(id)sender
{

}

- (@action)cancel:(id)sender
{
    [self orderOutWithAnimation:sender];
}

@end