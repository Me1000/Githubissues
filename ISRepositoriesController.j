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


@implementation ISRepositoriesController : CPObject
{
    @outlet ISIssuesController issuesController;

    // Temporary outlet. Will soon be replaced with a content binding.
    @outlet ISModel model @accessors;

    CPTableView sourceList @accessors;
    CPTableView filterlist @accessors;
}

- (void)addRepo:(ISRepository)aRepo
{

}

/*
    Remove the selected repo
*/
- (void)removeRepo:(id)sender
{
    var repo = [model repositories][[[sourceList selectedRowIndexes] firstIndex]];

    [repo removeObserver:self forKeyPath:"isPrivate"];
    [repo removeObserver:self forKeyPath:"numberOfOpenIssues"];
    [repo removeObserver:self forKeyPath:"issuesAssignedToCurrentUser"];

    [[model repositories] removeObject:repo];

    [sourceList reloadData];
}

- (void)setSortedRepos:(CPArray)newRepos
{
    [model setRepositories:newRepos || []];

    // update everything dude...
    for (var i = 0, controller = [ISGithubAPIController sharedController]; i < [model repositories].length; i++)
    {
        var repo = [model repositories][i];

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
    if (![[model repositories] containsObject:aRepo])
    {
        [aRepo addObserver:self forKeyPath:"is_private" options:nil context:nil];
        [aRepo addObserver:self forKeyPath:"numberOfOpenIssues" options:nil context:nil];
        [aRepo addObserver:self forKeyPath:"issuesAssignedToCurrentUser" options:nil context:nil];

        [[model repositories] addObject:aRepo];
        [sourceList reloadData];
    }

    if (shouldSelect)
    {
        [sourceList selectRowIndexes:[CPIndexSet indexSetWithIndex:([[model repositories] count] -1)] byExtendingSelection:NO];

        // FIX ME: this should be required, but for someone must have changed it in CPTableView
        //[self tableViewSelectionDidChange:nil];
    }

    // update the defaults
    var defaults = [CPUserDefaults standardUserDefaults];
    [defaults setObject:[model repositories] forKey:"[model repositories]"];
}

- (void)observeValueForKeyPath:(id)path ofObject:(id)obj change:(id)change context:(id)context
{
console.log("changes");
    [sourceList reloadData];
}

- (int)numberOfRowsInTableView:(CPTableView)aTable
{
    return [[model repositories] count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return [model repositories][aRow];
}

- (void)tableViewSelectionDidChange:(CPTableView)aTable
{
    [issuesController setActiveRepository:[model repositories][[[sourceList selectedRowIndexes] firstIndex]]];
}

@end