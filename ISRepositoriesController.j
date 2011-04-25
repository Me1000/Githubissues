/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

/*!
    This class is a singleton that allows for the managing of repositories
    This also acts as the data source for the source list.
*/

var TEST_DATA = [
        { 'name': '280north/something',     'is_private': YES,  'mine': 9,  'open': 31 },
        { 'name': '280north/issues',        'is_private': NO,   'mine': 9,  'open': 29 },
        { 'name': '280north/cappuccino',    'is_private': NO,   'mine': 15, 'open': 27 },
        { 'name': 'janl/mustache',          'is_private': NO,   'mine': 0,  'open': 18 },
        { 'name': 'joyent/node',            'is_private': NO,   'mine': 0,  'open': 21 }
    ];



@implementation ISRepositoriesController : CPObject
{
    @outlet ISIssuesController issuesController;

    CPArray sortedRepos;
    CPTableView sourceList @accessors;
    CPTableView filterlist @accessors;
}

- (id)init
{
    self = [super init];

    sortedRepos = [];

    return self;
}

- (void)addRepo:(ISRepository)aRepo
{
    
}

/*
    Remove the selected repo
*/
- (void)removeRepo:(id)sender
{
    var repo = sortedRepos[[[sortedRepos selectedRowIndexes] firstIndex]];

    [repo removeObserver:self forKeyPath:"isPrivate"];
    [repo removeObserver:self forKeyPath:"numberOfOpenIssues"];
    [repo removeObserver:self forKeyPath:"issuesAssignedToCurrentUser"];

    [sortedRepos removeObject:repo];

    [sourceList reloadData];
}

- (void)setSortedRepos:(CPArray)newRepos
{
    sortedRepos = newRepos || [];

    // update everything dude...
    for (var i = 0, controller = [ISGithubAPIController sharedController]; i < sortedRepos.length; i++)
    {
        var repo = sortedRepos[i];

        [[controller repositoriesByIdentifier] setObject:repo forKey:[repo identifier]];

        [controller loadRepositoryWithIdentifier:[repo identifier] callback:function(){[sourceList reloadData];}];

        [repo addObserver:self forKeyPath:"is_private" options:nil context:nil];
        [repo addObserver:self forKeyPath:"numberOfOpenIssues" options:nil context:nil];
        [repo addObserver:self forKeyPath:"issuesAssignedToCurrentUser" options:nil context:nil];
    }

    // load the initial issues in the source list
    [sourceList reloadData];
}

- (void)addRepository:(ISRepository)aRepo select:(BOOL)shouldSelect
{
    if (![sortedRepos containsObject:aRepo])
    {
        [aRepo addObserver:self forKeyPath:"is_private" options:nil context:nil];
        [aRepo addObserver:self forKeyPath:"numberOfOpenIssues" options:nil context:nil];
        [aRepo addObserver:self forKeyPath:"issuesAssignedToCurrentUser" options:nil context:nil];

        [sortedRepos addObject:aRepo];
        [sourceList reloadData];
    }

    if (shouldSelect)
    {
        [sourceList selectRowIndexes:[CPIndexSet indexSetWithIndex:([sortedRepos count] -1)] byExtendingSelection:NO];

        // FIX ME: this should be required, but for someone must have changed it in CPTableView
        //[self tableViewSelectionDidChange:nil];
    }

    // update the defaults
    var defaults = [CPUserDefaults standardUserDefaults];
    [defaults setObject:sortedRepos forKey:"sortedRepos"];
}

- (void)observeValueForKeyPath:(id)path ofObject:(id)obj change:(id)change context:(id)context
{
console.log("changes");
    [sourceList reloadData];
}

- (int)numberOfRowsInTableView:(CPTableView)aTable
{
    return [sortedRepos count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return sortedRepos[aRow];
}

- (void)tableViewSelectionDidChange:(CPTableView)aTable
{
    [issuesController setActiveRepository:sortedRepos[[[sourceList selectedRowIndexes] firstIndex]]];
}

@end