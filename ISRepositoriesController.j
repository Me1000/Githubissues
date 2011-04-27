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
@implementation ISRepositoriesController : CPArrayController
{
    @outlet ISIssuesController issuesController;

    @outlet ISModel model @accessors;

    CPTableView sourceList @accessors;
    CPTableView filterlist @accessors;
}

- (void)awakeFromCib
{
    // TODO This could just as well be done in the CIB.
    [self bind:@"contentArray" toObject:model withKeyPath:@"repositories" options:nil];
}

- (void)addRepository:(ISRepository)aRepo select:(BOOL)shouldSelect
{
    if (![self canAdd])
        return;

    var repositories = [model repositories];
    if (![repositories containsObject:aRepo])
        [self addObject:aRepo];
    [aRepo load];

    // TODO Do this automatically somehow.
    [model save];
}

- (void)tableViewSelectionDidChange:(CPTableView)aTable
{
    // TODO Replace with a binding to selectionIndexes.
    [issuesController setActiveRepository:[[self selectedObjects] firstObject]];
}

@end