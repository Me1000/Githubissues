
/*!
    This class is a singleton that allows for the managing of repositories
    This also acts as the data source for the source list.
*/

var sharedController = nil;

@implementation ISRepositoriesController : CPObject
{
    CPArray sortedRepos;
    CPTableView sourceList @accessors;
    CPTableView filterlist @accessors;
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

- (int)numberOfRowsInTableView:(CPTableView)aTable
{
    return 10;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return aRow;
}

@end