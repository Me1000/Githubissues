/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

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