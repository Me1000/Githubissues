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
    var newRepo = [ISRepository new];

    [newRepo setIdentifier:( typeof anObject.owner === "string" ? anObject.owner : anObject.owner.login) + "/" + anObject.name];
    [newRepo setIsPrivate:anObject["private"]];
    [newRepo setNumberOfOpenIssues:anObject.open_issues];
    [newRepo setIssuesAssignedToCurrentUser:0];
    [newRepo setLabels:anObject['labels']];

    return newRepo;
}

- (id)init
{
    if (self = [super init])
    {
        labels = [];
    }
    return self;
}

- (CPArray)labels
{
    return labels;
}

- (void)setLabels:(CPArray)someLabels
{
    // Prevent mystery errors.
    if (someLabels === nil || someLabels === undefined || ![someLabels isKindOfClass:CPArray])
        [CPException raise:CPInvalidArgumentException reason:@"Labels must be an array."];
    labels = someLabels;
}

- (void)updateWithJSObject:(JSObject)anObject
{
    [self setIdentifier:( typeof anObject.owner === "string" ? anObject.owner : anObject.owner.login) + "/" + anObject.name];
    [self setIsPrivate:anObject["private"]];
    [self setNumberOfOpenIssues:anObject.open_issues];

    if (anObject.labels)
    {
        var labels = [],
            i = 0,
            c = anObject.labels.length;

        for (; i < c; i++)
            labels.push([ISLabel labelWithJSObject:anObject.labels[i]]);

        anObject.lables = labels;
    }
    else
        anObject.labels = [];

    [self setLabels:anObject.labels];

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
    labels              = [aCoder decodeObjectForKey:"labels"] || [];
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
//    [aCoder encodeObject:labels forKey:"labels"];
//    [aCoder encodeObject:open forKey:"open"];
//    [aCoder encodeObject:closed forKey:"closed"];
}

@end
