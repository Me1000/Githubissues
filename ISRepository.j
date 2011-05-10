/*
 * ISRepository.j
 * GithubIssues
 *
 * Created by Alexander Ljungberg on April 18, 2011.
 * Copyright 2011, WireLoad Inc. All rights reserved.
 */

/*!
    Represent a GitHub repo.
*/
@implementation ISRepository : CPObject
{
    CPString    name @accessors;
    CPString    owner @accessors;
    BOOL        isPrivate @accessors;
    int         numberOfOpenIssues @accessors;
    // TODO Come up with a better name.
    int         issuesAssignedToCurrentUser @accessors;

    CPArray     open @accessors;
    CPArray     closed @accessors;
    CPArray     collaborators;
    CPArray     collaboratorNames @accessors(readonly);
    CPArray     labels @accessors;
    CPArray     milestones @accessors;
}

+ (CPSet)keyPathsForValuesAffectingSidebarRepresentation
{
    return [CPSet setWithObjects:"identifier", "isPrivate", "numberOfOpenIssues", "issuesAssignedToCurrentUser"];
}

+ (CPSet)keyPathsForValuesAffectingIdentifier
{
    return [CPSet setWithObjects:"name", "owner"];
}

+ (id)repositoryWithJSObject:(JSObject)anObject
{
    var newRepo = [[ISRepository alloc] init];

    [newRepo setIdentifier:( typeof anObject.owner === "string" ? anObject.owner : anObject.owner.login) + "/" + anObject.name];
    [newRepo setIsPrivate:anObject["private"]];
    [newRepo setNumberOfOpenIssues:anObject.open_issues];
    [newRepo setIssuesAssignedToCurrentUser:0];

    return newRepo;
}

- (void)updateWithJSObject:(JSObject)anObject
{
    [self setIdentifier:( typeof anObject.owner === "string" ? anObject.owner : anObject.owner.login) + "/" + anObject.name];
    [self setIsPrivate:anObject["private"]];
    [self setNumberOfOpenIssues:anObject.open_issues];

    // FIX ME: can we do this, but fast?
    //[self setIssuesAssignedToCurrentUser:0];
}

- (void)addIssue:(CPDictionary)anIssue
{
    [open addObject:anIssue];
    [self setNumberOfOpenIssues:numberOfOpenIssues + 1];
}

- (void)setCollaborators:(CPArray)newCollabs
{
    collaborators = [];
    collaboratorNames = [];

    for (var i = 0, c = newCollabs.length; i < c; i++)
    {
        collaborators.push([CPDictionary dictionaryWithJSObject:newCollabs[i] recursively:YES]);
        collaboratorNames.push(newCollabs[i].login);
    }
}

/*!
    This is a proxy used to be able to bind the main repository sidebar column to a keypath which properly
    notifies when any of the values in the compound dataview change.
*/
- (ISRepository)sidebarRepresentation
{
    return self;
}

- (CPString)identifier
{
    return owner + "/" + name;
}

- (void)setIdentifier:(CPString)aString
{
    var pos = aString.indexOf("/");

    [self setOwner:[aString substringToIndex:pos]];
    [self setName:[aString substringFromIndex:pos+1]];
}

- (void)load
{
    var controller = [ISGithubAPIController sharedController];
    [[controller repositoriesByIdentifier] setObject:self forKey:[self identifier]];
    [controller loadRepositoryWithIdentifier:[self identifier] callback:nil];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];


    [self setIdentifier:[aCoder decodeObjectForKey:"identifier"]];
    isPrivate           = [aCoder decodeObjectForKey:"isPrivate"];
    numberOfOpenIssues  = [aCoder decodeObjectForKey:"numberOfOpenIssues"];
    issuesAssignedToCurrentUser = [aCoder decodeObjectForKey:"issuesAssignedToCurrentUser"];
//    open                = [aCoder decodeObjectForKey:"open"];
//    closed              = [aCoder decodeObjectForKey:"closed"];

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [aCoder encodeObject:[self identifier] forKey:"identifier"];
    [aCoder encodeObject:isPrivate forKey:"isPrivate"];
    [aCoder encodeObject:numberOfOpenIssues forKey:"numberOfOpenIssues"];
    [aCoder encodeObject:issuesAssignedToCurrentUser forKey:"issuesAssignedToCurrentUser"];
//    [aCoder encodeObject:open forKey:"open"];
//    [aCoder encodeObject:closed forKey:"closed"];
}

@end
