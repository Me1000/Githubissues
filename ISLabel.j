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
    CPString    name @accessors;
    CPURL       url @accessors;
    CPColor     color @accessors;
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

    return newLabel;
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
