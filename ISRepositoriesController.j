
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
    return TEST_DATA.length;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var r = [ISRepository new],
        testRow = TEST_DATA[aRow];
    // TODO Don't create a new object every call.
    [r setName:testRow.name];
    [r setIsPrivate:testRow.is_private];
    [r setOpenIssues:testRow.open];
    [r setIssuesAssignedToCurrentUser:testRow.mine];
    return r;
}

@end