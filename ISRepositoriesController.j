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

+ (CPSet)keyPathsForValuesAffectingSelectedObject
{
    return [CPSet setWithObjects:"selectedObjects"];
}

- (void)awakeFromCib
{
    // TODO This could just as well be done in the CIB.
    [self bind:@"contentArray" toObject:model withKeyPath:@"repositories" options:nil];
    [issuesController bind:@"activeRepository" toObject:self withKeyPath:@"selectedObject" options:nil];
}

/*!
    Exactly like 'selectedObjects' but always gets the first selected object or nothing.

    Observable.
*/
- (id)selectedObject
{
    var selectedObjects = [self selectedObjects];
    if (![selectedObjects count])
        return nil;
    return [selectedObjects firstObject];
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

- (void)remove:(id)sender
{
    [super remove:sender];

    // TODO Do this automatically somehow.
    [model save];
}

@end
