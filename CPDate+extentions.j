/*
    Used to parse github's dates which kind of suck.
*/

@implementation CPDate (extentions)
// FIX ME: 
+ (CPDate)dateFromISO8601:(CPString)aString
{
    return new Date();
}

/*!
    This method should return a string like
    "1 day ago"
    "1 week ago"

    of if it was more than ... say... 1 week ago
    "December 31st 2010"
*/
- (CPString)friendlyDateString
{
    return "December 31st 2010";
}

@end
