/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

/*!
    This class is used as the controller between the model (an array of issues)
    and the view (the list of issues).
*/

@implementation ISIssuesController : CPArrayController
{
            ISRepository activeRepository @accessors;

//            CPArray filteredIssues;

    @outlet CPView containerView;
    @outlet ISSortBar sortBar;
            CPScrollView scrollView;
            CPTableView issuesList;

            CPString visisbleIssuesKey;


    @outlet ISIssueDataView dataviewproto;

}

- (id)init
{
    self = [super init];

    visisbleIssuesKey = "open";

    return self;
}

- (void)_showIssues
{
    // For faster startup times we lazily load
    // the issues view
    if (!scrollView)
    {
        var containerSize = [containerView bounds],
            offsetHeight = [sortBar bounds].size.height;

        scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, offsetHeight, containerSize.size.width, containerSize.size.height - offsetHeight)];
        [scrollView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
        [containerView addSubview:scrollView];

        issuesList = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];
        [issuesList setDataSource:self];
        [issuesList setDelegate:self];

        var col = [[CPTableColumn alloc] initWithIdentifier:"issues"];
        [col setDataView:dataviewproto];
        [issuesList setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
        [issuesList setHeaderView:nil];
        [issuesList setCornerView:nil];
        [issuesList setRowHeight:60];

        [issuesList setAlternatingRowBackgroundColors:
                [
                    [CPColor colorWithRed:250/255 green:250/255 blue:250/255 alpha:1],
                    [CPColor colorWithRed:245/255 green:247/255 blue:247/255 alpha:1]
                ]
        ];
        [issuesList setUsesAlternatingRowBackgroundColors:YES];

        [issuesList setGridColor:[CPColor colorWithRed:218/255 green:225/255 blue:230/255 alpha:1]];
        [issuesList setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];

        [issuesList setSelectionHighlightColor:[CPColor colorWithRed:216/255 green:230/255 blue:240/255 alpha:1]];

        [scrollView setDocumentView:issuesList];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setAutohidesScrollers:YES];
        [issuesList addTableColumn:col];

        [issuesList sizeLastColumnToFit];

        [col bind:CPValueBinding toObject:self withKeyPath:"arrangedObjects" options:nil];
//        [self bind: toObject: withKeyPath: options:]
    }

    if (!activeRepository)
    {
        // Make sure the table knows we have 0 rows now.
        [self setContent:[]];
        return;
    }

    var issues = [activeRepository valueForKey:visisbleIssuesKey];
    if (issues)
    {
        // Reapply the current search to the new issues.
        [self searchDidChange:nil];

        // FIX ME: find the currently selected item
        // Then after the reload call reselect that item if it still exists.
        //[issuesList reloadData];
        [self setContent:issues];
    }
    else
        [[ISGithubAPIController sharedController] loadIssuesForRepository:activeRepository state:visisbleIssuesKey callback:nil];
}

- (@action)searchDidChange:(id)sender
{
    // FIX ME: filter bar and better predicate stuff

    if (![sender stringValue])
        var filter = nil;
    else
        var filter = [CPPredicate predicateWithFormat:"title like[cd] %@", [sender stringValue]];

    [self setFilterPredicate:filter];
}

// FIX ME: maybe we should just call setSortDescriptors: directly
- (void)sortDescriptorsDidChange:(CPArray)newSortDescriptors
{
    [self setSortDescriptors:newSortDescriptors];
}

/*!
    Sets the active repository,
    This method registers observers for the visible issue key.
*/
- (void)setActiveRepository:(ISRepository)aRepo
{
    // Remove the previous observer
    [activeRepository removeObserver:self forKeyPath:visisbleIssuesKey];

    activeRepository = aRepo;
    [self setContent:[activeRepository valueForKey:visisbleIssuesKey]];

    //Add a new observer
    [activeRepository addObserver:self forKeyPath:visisbleIssuesKey options:nil context:nil];

    [self _showIssues];
}

/*!
    When the visisble issues key (open/closed) changes
    we redisplay new issues.
*/
- (void)observeValueForKeyPath:(id)path ofObject:(id)obj change:(id)change context:(id)context
{
    if (obj !== activeRepository)
        return;

    [self _showIssues];
}

/*!
    Sent by the assignee button
*/
- (@action)_assignee:(id)sender
{
    [CPMenu popUpContextMenu:[self _assigneesMenu] withEvent:[CPApp currentEvent] forView:sender];
}

/*!
    Returns the menu for assignee.
*/
- (CPMenu)_assigneesMenu
{
    var menu = [[CPMenu alloc] init];

    var assignees = [activeRepository collaboratorNames],
        count = [assignees count];

    for (var i = 0; i < count; i++)
    {
        var assignee = assignees[i],
            item = [[CPMenuItem alloc] initWithTitle:assignee action:@selector(_toggleTag:) keyEquivalent:nil];

        if (assignee.isUsed)
            [item setState:CPOnState];

        [item setTarget:self];
        [item setTag:assignee];
        [menu addItem:item];
    }

    return menu;
}

/*!
    The action of the milestone button.
    This method creates a popup menu for the button.
*/
- (@action)_milestones:(id)aSender
{
    [CPMenu popUpContextMenu:[self _milestonesMenu] withEvent:[CPApp currentEvent] forView:aSender];
}

/*!
    Returns a CPMenu for the label setting thingy for the selected item
*/
- (CPMenu)_milestonesMenu
{
    var menu = [[CPMenu alloc] init],
        newItem = [[CPMenuItem alloc] initWithTitle:@"New Milestone" action:@selector(newMilestone:) keyEquivalent:nil];

    [newItem setTarget:self];

    [menu addItem:newItem];

    var milestones = [self _milestonesForSelectedIssues],
        count = [milestones count];

    if (count)
        [menu addItem:[CPMenuItem separatorItem]];

    for (var i = 0; i < count; i++)
    {
        var milestone = milestones[i],
            item = [[CPMenuItem alloc] initWithTitle:[milestone objectForKey:"title"] action:@selector(_toggleLabel:) keyEquivalent:nil];

        if ([milestone objectForKey:"isUsed"])
            [item setState:CPOnState];

        [item setTarget:self];
        [item setTag:milestone];
        [menu addItem:item];
    }

    return menu;
}

/*!
    Returns an array of the milestones.
    This has an extra property isUsed
*/
- (CPArray)_milestonesForSelectedIssues
{
    // FIX ME: actually make use of isUsed.

    return [activeRepository milestones];
}

- (void)newMilestone:(sender)aSender
{
    alert("do this");
}


/*!
    Sent by the assignee button
*/
- (@action)_label:(id)sender
{
    [CPMenu popUpContextMenu:[self _labelsMenu] withEvent:[CPApp currentEvent] forView:sender];
}

/*!
    Returns the menu for assignee.
*/
- (CPMenu)_labelsMenu
{
    var menu = [[CPMenu alloc] init],
        newItem = [[CPMenuItem alloc] initWithTitle:@"New Label" action:@selector(newLabel:) keyEquivalent:nil];

    [newItem setTarget:self];

    [menu addItem:newItem];

    var labels = [self _labelsForSelectedIssue],
        count = [labels count];

    if (count)
        [menu addItem:[CPMenuItem separatorItem]];

    for (var i = 0; i < count; i++)
    {
        var label = labels[i],
            item = [[CPMenuItem alloc] initWithTitle:[label objectForKey:"name"] action:@selector(_toggleTag:) keyEquivalent:nil];

        if ([label objectForKey:"isUsed"])
            [item setState:CPOnState];

        [item setTarget:self];
        [item setTag:label];
        [menu addItem:item];
    }

    return menu;
}

/*!
    Returns a dictionary of labels for the selected item.
    This is specific to a single itme becuase it has an isUsed
    key for each item.
*/
- (CPArray)_labelsForSelectedIssue
{
    var allLabels = [activeRepository labels],
        newLabels = [CPArray arrayWithDeepCopyOfArray:allLabels],
        usedLabels = [[self selectedObjects][0] objectForKey:"labels"],
        i = 0,
        c = allLabels.length;

    for (; i < c; i++)   
        [newLabels[i] setObject:[usedLabels containsObject:allLabels[i]] forKey:"isUsed"];

console.log(allLabels, newLabels);

    return newLabels;
}

/*!
    This method actually creates a NEW label
*/
- (@action)newLabel:(id)aSender
{
    // FIX ME:
    alert("DO THIS");
    //[[[NewTagController alloc] init] showWindow:self];
}

/*!
    This method toggles a particular label
*/
- (@action)toggleLabel:(id)aSender
{
    // FIX ME: this probably doesnt work
    var label = [aSender tag],
        selector = [label objectForKey:"isUsed"] ? @selector(unsetLabelForSelectedIssue:) : @selector(setLabelForSelectedIssue:);

    [self performSelector:selector withObject:label];
}

- (void)unsetLabelForSelectedIssue:(CPDictionary)aLabel
{

}

- (void)setLabelForSelectedIssue:(CPDictionary)aLabel
{

}

- (void)visisbleIssuesSelectionDidChange:(BOOL)aOpenIssuesAreSelected
{
    // Remove the previous observer
    [activeRepository removeObserver:self forKeyPath:visisbleIssuesKey];

    // Change the key and add a new observer
    visisbleIssuesKey = aOpenIssuesAreSelected ? "open" : "closed";
    [activeRepository addObserver:self forKeyPath:visisbleIssuesKey options:nil context:nil];

    [self _showIssues];
}
@end

@implementation CPArray (deepcopy)
+ (CPArray)arrayWithDeepCopyOfArray:(CPArray)anArray
{
    var newArray = [],
        i = 0,
        c = anArray.length;

    for (; i < c; i++)
        newArray.push([anArray[i] copy]);

    return newArray;
}
@end