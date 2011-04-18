var kSortBarHeight = 36;

/*!
    This view represents a bar used for sorting issues
*/

@implementation ISSortBar : CPView
- (void)awakeFromCib
{
    [self setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("sortbar_backgroung.png", 21, 36)]];


    // FIX ME: I'm sure this can be done easier
    var items = ["ID", "Title", "Created", "Updated"],
        c = items.length,
        i = 0,
        origin = CGPointMakeZero();

    for (; i < c; i++)
    {
        
        var sub = [[ISSortItem alloc] initWithTitle:items[i] sortDescriptor:nil];

        [sub setFrameOrigin:origin];
        [self addSubview:sub];

        origin.x += [sub frameSize].width;
    }
}
@end

/*!
    A sort item represents a view in the sort bar
    Sort items have two properties
        - A sort descriptor
        - A title
*/
@implementation ISSortItem : CPButton
{
    CPSortDescriptor sortdescriptor @accessors;
    CPImage          sortImageUp;
    CPImage          sortImageDown;
}

- (id)initWithTitle:(CPString)aTitle sortDescriptor:(CPSortDescriptor)aSortDescriptor
{
    self = [super initWithFrame:CGRectMake(0,0,100,24)];

    [self setValue:[CPColor clearColor] forThemeAttribute:"bezel-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[resourcesImage("sortbar-active-left.png", 3, 35), resourcesImage("sortbar-active-center.png", 27, 36), resourcesImage("sortbar-active-right.png", 3, 36)] isVertical:NO]] forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];

    [self setTitle:aTitle];
    [self sizeToFit];

    sortImageUp = resourcesImage("FIXME_arrowdown.png", 10, 10);
    sortImageDown = resourcesImage("FIXME_arrowdown.png", 10, 10);

    [self setImage:sortImageUp];
    [self setImagePosition:CPImageRight];

    var size = [self frameSize];

    size.width += 34;
    size.height = kSortBarHeight;
    [self setFrameSize:size];

    return self;
}

@end