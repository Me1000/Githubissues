/*
 * AppController.j
 * GithubIssues
 *
 * Created by Alexander Ljungberg on April 14, 2011.
 * Copyright 2011, WireLoad LLC All rights reserved.
 */

/*
 * ISRepository.j
 * GithubIssues
 *
 * Created by Alexander Ljungberg on April 18, 2011.
 */

/*!
    Represent a GitHub repo.
*/
@implementation ISRepository : CPObject
{
    CPString    name @accessors;
    BOOL        isPrivate @accessors;
    int         openIssues @accessors;
    // TODO Come up with a better name.
    int         issuesAssignedToCurrentUser @accessors;
}

@end
