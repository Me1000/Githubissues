/*!
    The document model. Each instance represents a specific user environment where one or more repositories have been added and possibly rearranged.
*/

@import "ISRepository.j"

var TEST_REPO_DATA = [
        { 'name': '280north/something',     'is_private': YES,  'mine': 9,  'open': 31 },
        { 'name': '280north/issues',        'is_private': NO,   'mine': 9,  'open': 29 },
        { 'name': '280north/cappuccino',    'is_private': NO,   'mine': 15, 'open': 27 },
        { 'name': 'janl/mustache',          'is_private': NO,   'mine': 0,  'open': 18 },
        { 'name': 'joyent/node',            'is_private': NO,   'mine': 0,  'open': 21 }
    ];

ISModelRepositoriesKey = "sortedRepos";

@implementation ISModel : CPObject
{
    CPMutableArray repositories @accessors;
}

- (void)init
{
    if (self = [super init])
    {
        repositories = [];
    }
    return self;
}

- (void)load
{
    // Load the defaults.
    var defaults = [CPUserDefaults standardUserDefaults],
        sortedRepos = [defaults objectForKey:ISModelRepositoriesKey];
    [self setRepositories:sortedRepos || []];

    // Make sure all repos are loaded from the API.
    [repositories makeObjectsPerformSelector:@selector(load)];
}

- (void)save
{
    var defaults = [CPUserDefaults standardUserDefaults];
    [defaults setObject:[repositories copy] forKey:ISModelRepositoriesKey];
}

@end