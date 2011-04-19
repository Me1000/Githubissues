/*!
    This class is used as the controller between the model (an array of issues)
    and the view (the list of issues).
*/

@implementation ISIssuesController : CPObject
{
    CPArray sortedIssues;
    CPArray filteredIssues;
}

- (void)sortDescriptorsDidChange:(CPArray)newSortDescriptors
{
    console.log(newSortDescriptors);
}

@end