/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

/*!
    ISToolbar represents a simple view that acts as a toolbar.
    There are various reasons we're not using a CPToolbar here,
    mostly because this view will be much more customizable. But
    also because this will give us more flexibility.
*/
@implementation ISToolbar : CPView
{
            CPView selectedTabView;

    @outlet CPButton openIssuesButton;
    @outlet CPButton closedIssuesButton;


            BOOL openIssuesSelected @accessors;

    @outlet  id      visisbleIssuesSelectionDelegate;
}
- (void)awakeFromCib
{
    openIssuesSelected = YES;

    [self setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("toolbarbg.png", 33, 46)]];

    var frame = [openIssuesButton frame];
    selectedTabView = [[CPView alloc] initWithFrame:CGRectMake(frame.origin.x, 14, frame.size.width, 32)];

    var pattern = [[CPThreePartImage alloc] initWithImageSlices:[resourcesImage("selectedtab-left.png", 15, 32), resourcesImage("selectedtab-center.png", 1, 32), resourcesImage("selectedtab-right.png", 15, 32)] isVertical:NO]

    [selectedTabView setBackgroundColor:[CPColor colorWithPatternImage:pattern]];
    [self addSubview:selectedTabView positioned:CPWindowBelow relativeTo:closedIssuesButton];

    [openIssuesButton setBordered:NO];
    [closedIssuesButton setBordered:NO];

    [closedIssuesButton setValue:[CPColor colorWithRed:122/255 green:140/255 blue:153/255 alpha:1] forThemeAttribute:"text-color"];
    [openIssuesButton setValue:[CPColor colorWithRed:122/255 green:140/255 blue:153/255 alpha:1] forThemeAttribute:"text-color"];

    [closedIssuesButton setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.2] forThemeAttribute:"text-shadow-color"];
    [closedIssuesButton setValue:CGSizeMake(0,1) forThemeAttribute:"text-shadow-offset"];

    [openIssuesButton setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.2] forThemeAttribute:"text-shadow-color"];
    [openIssuesButton setValue:CGSizeMake(0,1) forThemeAttribute:"text-shadow-offset"];


}

- (void)splitViewMovedTo:(float)aPosition
{
    [openIssuesButton setFrameOrigin:CGPointMake(aPosition, [openIssuesButton frameOrigin].y)];

    var endOfOpenButton = CGRectGetMaxX([openIssuesButton frame]);
    [closedIssuesButton setFrameOrigin:CGPointMake(endOfOpenButton, [closedIssuesButton frameOrigin].y)];

        var origin = CGPointMake(openIssuesSelected ? aPosition : endOfOpenButton, 14);

    [selectedTabView setFrameOrigin:origin];
}

- (@action)changeIssuesStatus:(id)sender
{
    var senderFrame = [sender frame],
        dict = [[CPDictionary alloc] initWithObjects:[selectedTabView, [selectedTabView frame], CGRectMake(senderFrame.origin.x, 14, senderFrame.size.width, 32)] forKeys:[CPViewAnimationTargetKey, CPViewAnimationStartFrameKey, CPViewAnimationEndFrameKey]],
        ani = [[CPViewAnimation alloc] initWithViewAnimations:[dict]];

    [ani setDuration:0.1];
    [ani startAnimation];


    openIssuesSelected = (sender === openIssuesButton);
    [visisbleIssuesSelectionDelegate visisbleIssuesSelectionDidChange:openIssuesSelected];
/*
    var inactive = sender === openIssuesButton ? openIssuesButton : closedIssuesButton;

    [inactive setValue:[CPColor colorWithRed:122/255 green:140/255 blue:153/255 alpha:1] forThemeAttribute:"text-color"];
    [inactive setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.35] forThemeAttribute:"text-shadow-color"];

    [sender setValue:[CPColor colorWithRed:122/255 green:140/255 blue:153/255 alpha:1] forThemeAttribute:"text-color"];
    [sender setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.35] forThemeAttribute:"text-shadow-color"];
*/
}
@end
