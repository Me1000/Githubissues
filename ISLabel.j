/*
 * ISLabel.j
 * GithubIssues
 *
 * Created by Alexander Ljungberg on May 11, 2011.
 * Copyright 2011, WireLoad Inc. All rights reserved.
 */

/*!
    Represent a GitHub label.
*/
@implementation ISLabel : CPObject
{
    unsigned    labelID @accessors;
    CPString    name @accessors;
    CPURL       url @accessors;
    CPColor     color @accessors;
    unsigned    numberOfIssues @accessors;
}

+ (CPSet)keyPathsForValuesAffectingSidebarRepresentation
{
    return [CPSet setWithObjects:"name", "color"];
}

+ (id)labelWithJSObject:(JSObject)anObject
{
    var newLabel = [ISLabel new];

    [newLabel setName:anObject['name']];
    [newLabel setUrl:[CPURL URLWithString:anObject['url']]];
    [newLabel setColor:[CPColor colorWithHexString:anObject['color']]];

    [newLabel setLabelID:[[url pathComponents] lastObject]];

    return newLabel;
}

- (id)copy
{
    var newLabel = [ISLabel new];

    newLabel.name = name;
    newLabel.url = url;
    newLabel.color = color;
    newLabel.numberOfIssues = numberOfIssues;;

    return newLabel;
}

- (BOOL)isEqual:(ISLabel)anotherLabel
{
    // If the URLs are the same then they represent the same label
    // on Github, thus they must be equal. 
    return [anotherLabel url] === url;
}

- (id)init
{
    self = [super init];

    numberOfIssues = 0;

    return self;
}

- (BOOL)isUsed
{
    return numberOfIssues > 0;
}

/*!
    This is a proxy used to be able to bind the main label sidebar column to a keypath which properly
    notifies when any of the values in the compound dataview change.
*/
- (ISLabel)sidebarRepresentation
{
    return self;
}

@end
