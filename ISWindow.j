/*!
    Created by Randy Luecke April 22nd, 2011
    Copyright RCLConcepts, LLC. All right reserved

    used for the awesome translucent windows
*/

var WindowBackground = nil,
    DetachedWindowBackground = nil,
    GreenButtonColor = nil,
    GreenButtonDownColor = nil,
    RedButtonColor = nil,
    RedButtonDownColor = nil,
    GreenButtonDisabledColor = nil,
    RedButtonDisabledColor = nil;

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

    DetachedWindowBackground = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:[
        resourcesImage("windows/popoverwindow-0-no-spike.png", 65, 53),
        resourcesImage("windows/popoverwindow-1.png", 17, 53),
        resourcesImage("windows/popoverwindow-2.png", 44, 53),

        resourcesImage("windows/popoverwindow-3.png", 65, 48),
        resourcesImage("windows/popoverwindow-4.png", 17, 48),
        resourcesImage("windows/popoverwindow-5.png", 44, 48),

        resourcesImage("windows/popoverwindow-6.png", 65, 62),
        resourcesImage("windows/popoverwindow-7.png", 17, 62),
        resourcesImage("windows/popoverwindow-8.png", 44, 62)
    ]]];

    GreenButtonColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("green-button-0.png", 13, 23),
        resourcesImage("green-button-1.png", 2, 23),
        resourcesImage("green-button-2.png", 13, 23)
    ] isVertical:NO]];

    RedButtonColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("red-button-0.png", 13, 23),
        resourcesImage("red-button-1.png", 2, 23),
        resourcesImage("red-button-2.png", 13, 23)
    ] isVertical:NO]];

    GreenButtonDownColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("green-button-down-0.png", 13, 23),
        resourcesImage("green-button-down-1.png", 2, 23),
        resourcesImage("green-button-down-2.png", 13, 23)
    ] isVertical:NO]];

    RedButtonDownColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("red-button-down-0.png", 13, 23),
        resourcesImage("red-button-down-1.png", 2, 23),
        resourcesImage("red-button-down-2.png", 13, 23)
    ] isVertical:NO]];

    RedButtonDisabledColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("red-button-disabled-0.png", 13, 23),
        resourcesImage("red-button-disabled-1.png", 2, 23),
        resourcesImage("red-button-disabled-2.png", 13, 23)
    ] isVertical:NO]];

    GreenButtonDisabledColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
        resourcesImage("green-button-disabled-0.png", 13, 23),
        resourcesImage("green-button-disabled-1.png", 2, 23),
        resourcesImage("green-button-disabled-2.png", 13, 23)
    ] isVertical:NO]];
}

- (void)awakeFromCib
{
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
    @outlet CPTextField               repoNameField;
    @outlet CPButton                  submitButton;
    @outlet CPButton                  cancelButton;
    @outlet CPTextField               errorLabel;
    @outlet ISLoadingIndicator        loadingIndicator;

    @outlet ISRepositoriesController  repoController;

            CPScrollView              scrollview;
            CPTableView               suggestTable;
            CPArrayController         suggestedReposController;
}

+ (id)sharedWindow
{
    return SharedNewRepoWindow;
}

- (void)awakeFromCib
{
    [self setDelegate:self];

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


    [submitButton setValue:GreenButtonColor forThemeAttribute:"bezel-color"];
    [submitButton setValue:GreenButtonDownColor forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];
    [submitButton setValue:GreenButtonDisabledColor forThemeAttribute:"bezel-color" inState:CPThemeStateDisabled];

    [submitButton setValue:[CPColor whiteColor] forThemeAttribute:"text-color"];
    [submitButton setValue:[CPColor blackColor] forThemeAttribute:"text-shadow-color"];
    [submitButton setValue:[CPColor colorWithRed:59/255 green:89/255 blue:49/255 alpha:1] forThemeAttribute:"text-color" inState:CPThemeStateBordered|CPThemeStateDisabled];
    [submitButton setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.2] forThemeAttribute:"text-shadow-color" inState:CPThemeStateDisabled];
    [submitButton setValue:[CPFont boldSystemFontOfSize:11] forThemeAttribute:"font"];

    [cancelButton setValue:RedButtonColor forThemeAttribute:"bezel-color"];
    [cancelButton setValue:RedButtonDownColor forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];
    //[cancelButton setValue:RedButtonDisabledColor forThemeAttribute:"bezel-color" inState:CPThemeStateDisabled];
    [cancelButton setValue:[CPColor whiteColor] forThemeAttribute:"text-color"];
    [cancelButton setValue:[CPColor blackColor] forThemeAttribute:"text-shadow-color"];
    [submitButton setValue:[CPFont boldSystemFontOfSize:11] forThemeAttribute:"font"];

    [repoNameField setDelegate:self];

    [errorLabel sizeToFit];
}

- (void)showWindow:(id)sender
{
    var pt = [sender bounds],
        pt = [sender  convertRect:pt toView:nil],
        origin = CGPointMake(CGRectGetMidX(pt), CGRectGetMidY(pt));

    // offset for the spiky thing
    origin.x -= 52;

    [self setFrameOrigin:origin];

    [[self contentView] setBackgroundColor:WindowBackground];

    [self setAnimationLocation:"15% 0%"];
    [self setAnimationLength:"170"];
    [self orderFontWithAnimation:sender];
    [self makeKeyWindow];

    [submitButton setEnabled:NO];
}

- (void)controlTextDidChange:(CPNotification)aNote
{
    [submitButton setEnabled:[self _isValid]];

    var currentFrame = [self frame];

    if ([[repoNameField stringValue] length])
    {
        if (!CGSizeEqualToSize(currentFrame.size, CGSizeMake(381, 365)))
        {

            var visible = [CPPlatform isBrowser] ? [[self platformWindow] visibleFrame] : [[[CPScreen alloc] init] visibleFrame],
                realY = (currentFrame.origin.y + 364 > visible.size.height) ? visible.size.height - 364 : currentFrame.origin.y,
                y = MAX(realY,0),
                offset = MAX(y - realY, 0); // This will prevent it from ever being too large... unless it's < 364

                [self setFrame:CGRectMake(currentFrame.origin.x, y, 381, MIN(364, 364 + offset)) display:YES animate:[self isVisible]];

                // FIX ME: If we do this while the window is animating it'll likely result in a terrible frame rate.
                // set it up
                if (!scrollview)
                {
                    suggestedReposController = [[CPArrayController alloc] init];
                    [suggestedReposController setAvoidsEmptySelection:NO];

                    // FIX ME: use HUD style.
                    scrollview = [[CPScrollView alloc] initWithFrame:CGRectMake(11, 100, 356, 200)];
                    suggestTable = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];

                    var col = [[CPTableColumn alloc] initWithIdentifier:"Suggestions"];
                    [suggestTable addTableColumn:col];
                    [col bind:CPValueBinding toObject:suggestedReposController withKeyPath:"arrangedObjects.identifier" options:nil];

                    var dv = [[CPTextField alloc] init];
                    [dv setValue:[CPColor colorWithHexString:"cccccc"] forThemeAttribute:"text-color"];
                    [dv setFont:[CPFont systemFontOfSize:11]];
                    [col setDataView:dv];

                    [suggestTable setHeaderView:nil];
                    [suggestTable setCornerView:nil];

                    [scrollview setDocumentView:suggestTable];
                    [suggestTable sizeLastColumnToFit];

                    [suggestTable setTarget:self];
                    [suggestTable setDoubleAction:@selector(_setRepoAndAdd:)];

                    [scrollview setHasHorizontalScroller:NO];
                    [scrollview setAutohidesScrollers:YES];

                    [suggestTable setAlternatingRowBackgroundColors:[[CPColor colorWithHexString:"242c31"], [CPColor colorWithHexString:"262e33"]]];
                    [suggestTable setUsesAlternatingRowBackgroundColors:YES];
                    [suggestTable setSelectionHighlightColor:[CPColor colorWithHexString:"364046"]];
                    [suggestTable setAllowsEmptySelection:YES];
                }

                // Wait for the window to finish animating
                window.setTimeout(function(){
                   [[self contentView] addSubview:scrollview];
                },200);
        }

        // Make calls to the Search API
        [[ISGithubAPIController sharedController] repoSuggestWithSearchString:[repoNameField stringValue] callback:function(/*CPArray*/results){
            [suggestedReposController setContent:results];
        }];
    }
    else
    {
        if (!CGSizeEqualToSize(currentFrame.size, CGSizeMake(381,161)))
        {
            [scrollview removeFromSuperview];
            [self setFrame:CGRectMake(currentFrame.origin.x, currentFrame.origin.y, 381,161) display:YES animate:YES];
        }
    }
}

- (void)windowDidMove:(CPNotification)aNote
{
    [[self contentView] setBackgroundColor:DetachedWindowBackground];
}

- (@action)addRepo:(id)sender
{
    if (![self _isValid])
        return;

    var callback = function(aRepo, aRequest)
    {
        [loadingIndicator stopAnimating];
        [loadingIndicator setHidden:YES];
        [repoNameField setEnabled:YES];

        if (!aRequest.success())
        {
            [errorLabel setHidden:NO];
            return;
        }

        [repoController addRepository:aRepo select:YES];
        [self orderOutWithAnimation:sender];

        // wait for the window to disapear before removing the text.
        window.setTimeout(function(){

            [repoNameField setStringValue:""];
            [self controlTextDidChange:nil];
        },230);
    }

    [[ISGithubAPIController sharedController] loadRepositoryWithIdentifier:[repoNameField stringValue] callback:callback];
    [repoNameField setEnabled:NO];
    [errorLabel setHidden:YES];
    [loadingIndicator setHidden:NO];
    [loadingIndicator startAnimating];
}

- (@action)cancel:(id)sender
{
    [self orderOutWithAnimation:sender];

    window.setTimeout(function(){
        [repoNameField setStringValue:""];
        [self controlTextDidChange:nil];
    },230);
}

- (BOOL)_isValid
{
    var slashPosition =  [repoNameField stringValue].indexOf("/");
        enabled = ([[repoNameField stringValue] length] > 2 && slashPosition !== CPNotFound && slashPosition !== 0 && slashPosition !== [[repoNameField stringValue] length] -1);

    return enabled;
}

- (void)sendEvent:(CPEvent)anEvent
{
    if ([anEvent type] === CPKeyUp)
    {
        var excludedKeys = [CPUpArrowKeyCode, CPDownArrowKeyCode];

        if ([anEvent keyCode] === CPEscapeKeyCode)
            [self cancel:self];
        else if ([anEvent keyCode] === CPReturnKeyCode)
        {
            var sender = [self firstResponder];

            if (sender === suggestTable)
                [self _setRepoAndAdd:sender];
            else
                [self addRepo:sender];

            // prevent the call to super
            return;
        }
        else if ([self firstResponder] !== repoNameField && ![excludedKeys containsObject:[anEvent keyCode]])
            [self makeFirstResponder:repoNameField];
        else if ([excludedKeys containsObject:[anEvent keyCode]])
            [self makeFirstResponder:suggestTable];
    }

    // FIX ME: this is broked.
    [submitButton setEnabled:([self _isValid] || [self firstResponder] === suggestTable)];

    [super sendEvent:anEvent];
}

- (void)_setRepoAndAdd:(id)sender
{
    var index = [[suggestTable selectedRowIndexes] firstIndex];
    [repoNameField setStringValue:[[suggestedReposController contentArray][index] identifier]];

    [self addRepo:sender];
}

@end

@implementation ISNewIssueWindow : ISWindow
{
    @outlet CPTextField titleField;
    @outlet CPPopUpButton repoField;
    @outlet LPMultiLineTextField bodyField;

    @outlet CPButton saveButton;
    @outlet CPButton cancelButton;
    @outlet CPButton previewButton;
}

@end