/*!
    The document model. Each instance represents a specific user environment where one or more repositories have been added and possibly rearranged.
*/

var TEST_REPO_DATA = [
        { 'name': '280north/something',     'is_private': YES,  'mine': 9,  'open': 31 },
        { 'name': '280north/issues',        'is_private': NO,   'mine': 9,  'open': 29 },
        { 'name': '280north/cappuccino',    'is_private': NO,   'mine': 15, 'open': 27 },
        { 'name': 'janl/mustache',          'is_private': NO,   'mine': 0,  'open': 18 },
        { 'name': 'joyent/node',            'is_private': NO,   'mine': 0,  'open': 21 }
    ];

@implementation ISModel : CPObject
{
    CPMutableArray repositories @accessors;
}

- (void)awakeFromCib
{
    // Load the defaults.
    var defaults = [CPUserDefaults standardUserDefaults];
    [self setRepositories:[defaults objectForKey:"sortedRepos"] || []];
}

@end