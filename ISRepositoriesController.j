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

var sharedController = nil,

    TEST_DATA = [
        { 'name': '280north/something',     'is_private': YES,  'mine': 9,  'open': 31 },
        { 'name': '280north/issues',        'is_private': NO,   'mine': 9,  'open': 29 },
        { 'name': '280north/cappuccino',    'is_private': NO,   'mine': 15, 'open': 27 },
        { 'name': 'janl/mustache',          'is_private': NO,   'mine': 0,  'open': 18 },
        { 'name': 'joyent/node',            'is_private': NO,   'mine': 0,  'open': 21 }
    ];



@implementation ISRepositoriesController : CPObject
{
    CPArray sortedRepos;
    CPTableView sourceList @accessors;
    CPTableView filterlist @accessors;
}

- (void)awakeFromCib
{
    sharedController = self;
}

+ (id)sharedController
{
    if (!sharedController)
        sharedController = [[ISRepositoriesController alloc] init];

    return sharedController;
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

- (void)addRepository:(ISRepository)aRepo select:(BOOL)shouldSelect
{
    [sortedRepos addObject:aRepo];
    [sourceList reloadData];

    if (shouldSelect)
        [sourceList selectRowIndexes:[CPIndexSet indexSetWithIndex:([sortedRepos count] -1)] byExtendingSelection:NO];
}

- (int)numberOfRowsInTableView:(CPTableView)aTable
{
    return [sortedRepos count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return sortedRepos[aRow];
}

@end