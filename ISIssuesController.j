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

@implementation ISIssuesController : CPObject
{
            ISRepository activeRepository @accessors;

            CPArray filteredIssues;

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
    }

    if (!activeRepository)
    {
        // Make sure the table knows we have 0 rows now.
        [issuesList reloadData];
        return;
    }

    var issues = [activeRepository valueForKey:visisbleIssuesKey];
    if (issues)
    {
        // Reapply the current search to the new issues.
        [self searchDidChange:nil];

        // FIX ME: find the currently selected item
        // Then after the reload call reselect that item if it still exists.
        [issuesList reloadData];
    }
    else
        [[ISGithubAPIController sharedController] loadIssuesForRepository:activeRepository state:visisbleIssuesKey callback:nil];
}

- (void)searchDidChange:(id)sender
{
    // FIX ME: filter the issues
}

- (void)sortDescriptorsDidChange:(CPArray)newSortDescriptors
{
    console.log(newSortDescriptors);
}

- (void)setActiveRepository:(ISRepository)aRepo
{
    // Remove the previous observer
    [activeRepository removeObserver:self forKeyPath:visisbleIssuesKey];

    activeRepository = aRepo;

    //Add a new observer
    [activeRepository addObserver:self forKeyPath:visisbleIssuesKey options:nil context:nil];

    [self _showIssues];
}

- (void)observeValueForKeyPath:(id)path ofObject:(id)obj change:(id)change context:(id)context
{
console.log("changed",path, obj);
    if (obj !== activeRepository)
        return;

    if (path !== "open" && path !== "closed")
        console.log("OBSERVED VALUE IN ISISSUESCONTROLLER WAS NOT OPEN/CLOSED:::::::::::", path);

    [self _showIssues];
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


- (int)numberOfRowsInTableView:(CPTableView)aTable
{
    if (!activeRepository)
        return 0;

    if (filteredIssues)
        return [filteredIssues count];

    return [[activeRepository valueForKey:visisbleIssuesKey] count] || 0;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    if (!activeRepository)
        return nil;

    if (filteredIssues)
        return filteredIssues[aRow];

    return [activeRepository valueForKey:visisbleIssuesKey][aRow];
}

@end