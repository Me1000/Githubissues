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
    CPString    identifier @accessors;
    BOOL        isPrivate @accessors;
    int         numberOfOpenIssues @accessors;
    // TODO Come up with a better name.
    int         issuesAssignedToCurrentUser @accessors;

    CPArray     open @accessors;
    CPArray     closed @accessors;
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];

    name                = [aCoder decodeObjectForKey:"name"];
    identifier          = [aCoder decodeObjectForKey:"identifier"];
    isPrivate           = [aCoder decodeObjectForKey:"isPrivate"];
    numberOfOpenIssues  = [aCoder decodeObjectForKey:"numberOfOpenIssues"];
    issuesAssignedToCurrentUser = [aCoder decodeObjectForKey:"issuesAssignedToCurrentUser"];
//    open                = [aCoder decodeObjectForKey:"open"];
//    closed              = [aCoder decodeObjectForKey:"closed"];

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [aCoder encodeObject:name forKey:"name"];
    [aCoder encodeObject:identifier forKey:"identifier"];
    [aCoder encodeObject:isPrivate forKey:"isPrivate"];
    [aCoder encodeObject:numberOfOpenIssues forKey:"numberOfOpenIssues"];
    [aCoder encodeObject:issuesAssignedToCurrentUser forKey:"issuesAssignedToCurrentUser"];
//    [aCoder encodeObject:open forKey:"open"];
//    [aCoder encodeObject:closed forKey:"closed"];
}

@end
