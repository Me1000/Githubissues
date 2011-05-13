/*
 * CPArray+extensions.j
 * GithubIssues
 *
 * Created by Alexander Ljungberg on May 12, 2011.
 * Copyright 2011, WireLoad Inc. All rights reserved.
 */

@import "CPArray+extensions.j"

@implementation CPArray (CountUsingPredicate)

/*!
    Return the count of objects matching the predicate. This is a fast version of:

    <pre><code>
    [[array filteredArrayUsingPredicate:predicate] count];
    </code></pre>
*/
- (void)countUsingPredicate:(CPPredicate)predicate
{
    if (!predicate)
        return 0;

    var count = [self count],
        r = 0;

    while (count--)
    {
        if ([predicate evaluateWithObject:self[count]])
            r++;
    }

    return r;
}

/*!
    Because sometimes it's nice to have a deep copy of an array
*/
+ (CPArray)arrayWithDeepCopyOfArray:(CPArray)anArray
{
    var newArray = [],
        i = 0,
        c = anArray.length;

    for (; i < c; i++)
        newArray.push([anArray[i] copy]);

    return newArray;
}
@end
