@implementation CPArray (CountUsingPredicate)

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

@end