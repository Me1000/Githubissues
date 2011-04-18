/*!
    ISToolbar represents a simple view that acts as a toolbar.
    There are various reasons we're not using a CPToolbar here,
    mostly because this view will be much more customizable. But
    also because this will give us more flexibility.
*/
@implementation ISToolbar : CPView
- (void)awakeFromCib
{
    [self setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("toolbarbg.png", 33, 46)]];
}
@end
