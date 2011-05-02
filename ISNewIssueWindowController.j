@implementation ISNewIssueWindowController : CPWindowController
{
    CPArray repoTitles;
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];

    if (![sender isKindOfClass:[CPButton class]])
        return;

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

    [sender bind:"enabled" toObject:win withKeyPath:"isDetached" options:nil];
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

- (void)controlTextDidChange:(CPNotification)aNote
{
    var win = [self window],
        enable = NO;

    // FIX ME: Char count this < 50 should return NO.
    if ([[win titleField] stringValue] && [[win bodyField] stringValue])
        enable = YES;

    [[win saveButton] setEnabled:enable];
}

- (@action)cancel:(id)sender
{
    [[self window] orderOutWithAnimation:sender];
}

- (@action)addIssue:(id)sender
{
    // create a temparary issue object.
    var win = [self window],
        issue = [CPDictionary dictionaryWithObjects:[[[win titleField] stringValue], [[win bodyField] stringValue], [[win repoField] titleOfSelectedItem]] forKeys:["title", "body", "repo"]];

    [[ISGithubAPIController sharedController] createIssue:issue withCallback:function(newIssue, aRequest){
        if (!aRequest.success() && JSON.parse(aRequest.responseText()).message)
        {
            alert("make this a CPAlert I guess");
        }
    }];
}

- (@action)preview:(id)sender
{

}

- (@action)openInNewPlatformWindow:(id)sender
{
    if (![CPPlatform isBrowser] || ![CPPlatformWindow supportsMultipleInstances])
        return;

    var platformWindow = [[CPPlatformWindow alloc] initWithContentRect:CGRectMake(100, 100, 545, 350)];
    [platformWindow orderFront:self];
    [[self window] setPlatformWindow:platformWindow];
    [[self window] setFullBridge:YES];
}
@end