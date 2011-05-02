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
console.log("SENT:",[sender stringValue]);
    if (![sender stringValue])
    {
        [self setFilterPredicate:nil];
        return;
    }
    // FIX ME: filter the issues
    var filter = [CPPredicate predicateWithFormat:"title=%@", [sender stringValue]];
console.log("change something",filter);
    [self setFilterPredicate:filter];
}

// FIX ME: maybe we should just call setSortDescriptors: directly
- (void)sortDescriptorsDidChange:(CPArray)newSortDescriptors
{
    [self setSortDescriptors:newSortDescriptors];
}

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

- (void)_assigneesMenu
{
    var menu = [[CPMenu alloc] init];
//        newItem = [[CPMenuItem alloc] initWithTitle:@"New Tag" action:@selector(newTag:) keyEquivalent:nil];

//    [newItem setTarget:self];

//    [menu addItem:newItem];

    var assignees = [activeRepository collaboratorNames],
        count = [assignees count];

//    if (count)
//        [menu addItem:[CPMenuItem separatorItem]];

    for (var i = 0; i < count; i++)
    {
        var assignee = assignees[i],
            item = [[CPMenuItem alloc] initWithTitle:assignee action:@selector(_toggleTag:) keyEquivalent:nil];

        if (assignee.isUsed)
            [item setState:CPOnState];

        [item setTarget:self];
//        [item setTag:tag];
        [menu addItem:item];
    }

    return menu;
}


- (@action)_label:(id)aSender
{
    var toolbarView = [[aSender toolbar] _toolbarView],
        view = [toolbarView viewForItem:aSender];

    [CPMenu popUpContextMenu:[self _labelsMenu] withEvent:[CPApp currentEvent] forView:view];
}

- (CPMenu)_labelsMenu
{
    var menu = [[CPMenu alloc] init],
        newItem = [[CPMenuItem alloc] initWithTitle:@"New Label" action:@selector(newLabel:) keyEquivalent:nil];

    [newItem setTarget:self];

    [menu addItem:newItem];

    var tags = [self tagsForSelectedIssue],
        count = [tags count];

    if (count)
        [menu addItem:[CPMenuItem separatorItem]];

    for (var i = 0; i < count; i++)
    {
        var label = label[i],
            item = [[CPMenuItem alloc] initWithTitle:tag.label action:@selector(_toggleLabel:) keyEquivalent:nil];

        if (label.isUsed)
            [item setState:CPOnState];

        [item setTarget:self];
        [item setTag:label];
        [menu addItem:item];
    }

    return menu;
}

- (@action)newLabel:(id)aSender
{
    // FIX ME:
    alert("DO THIS");
    //[[[NewTagController alloc] init] showWindow:self];
}

- (@action)_toggleLabel:(id)aSender
{
    // FIX ME: this probably doesnt work
    var tag = [aSender tag],
        selector = tag.isUsed ? @selector(unsetTagForSelectedIssue:) : @selector(setTagForSelectedIssue:);

    [self performSelector:selector withObject:tag.label];
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


- (int)nuddmberOfRowsInTableView:(CPTableView)aTable
{
    if (!activeRepository)
        return 0;

    if (filteredIssues)
        return [filteredIssues count];

    return [[activeRepository valueForKey:visisbleIssuesKey] count] || 0;
}

- (id)tddableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    if (!activeRepository)
        return nil;

    if (filteredIssues)
        return [filteredIssues objectAtIndex:aRow];

    return [[activeRepository valueForKey:visisbleIssuesKey] objectAtIndex:aRow];
}

@end