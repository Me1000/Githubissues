@implementation ISNewIssueWindowController : CPWindowController
{
    CPArray repoTitles;
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];

    var pt = [sender bounds],
        pt = [sender  convertRect:pt toView:nil],
        origin = CGPointMake(CGRectGetMidX(pt), CGRectGetMidY(pt) + 3),
        win = [self window];

    // offset for the spiky thing
    origin.x -= 52;

    [win setFrameOrigin:origin];
    [win setAnimationLocation:"15% 0%"];
    [win setAnimationLength:"170"];
    [win orderFontWithAnimation:sender];
    [win makeKeyWindow];

    // this has to be done here because the window posts the didMove
    // notification when we change the origin point.
    [win setDelegate:win];
}

- (void)setRepos:(CPArray)theRepos
{
    repoTitles = theRepos;
}

- (void)selectRepo:(ISRepository)aRepo
{
    [[[self window] repoField] selectItemWithTitle:[aRepo identifier]];
}

- (void)loadWindow
{
    [super loadWindow];
    [[self window] setRepos:repoTitles];
}

- (@action)cancel:(id)sender
{
    [[self window] orderOutWithAnimation:sender];
}

- (@action)addIssue:(id)sender
{

}
- (@action)preview:(id)sender
{

}

@end