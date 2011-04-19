var kSortBarHeight = 36,
    blankImage     = nil;

/*!
    This view represents a bar used for sorting issues
*/

@implementation ISSortBar : CPView
{
            CPArray sortButtons;
            CPArray sortDescriptors;

    @outlet id      delegate @accessors;
    @outlet CPSearchField searchField;

            CPPopUpButton optionsPopupButton;
}
- (void)awakeFromCib
{
    [self setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("sortbar_backgroung.png", 21, 36)]];

    blankImage = resourcesImage("blank.png", 10, 10);

    // FIX ME: I'm sure this can be done easier
    var items = ["ID", "Title", "Created", "Updated", "Creator", "Pull Request"],
        keys  = ["id", "title", "created", "updated", "creator", "pull_request"],
        c = items.length,
        i = 0,
        origin = CGPointMake(45, 0);

    sortButtons = [];
    sortDescriptors = [];

    for (; i < c; i++)
    {
        var descriptor = [[CPSortDescriptor alloc] initWithKey:keys[i] ascending:YES],
            sub = [[ISSortItem alloc] initWithTitle:items[i] sortDescriptor:descriptor];

        [sortDescriptors addObject:descriptor];

        [sub setFrameOrigin:origin];
        [sub setTarget:self];
        [sub setAction:@selector(buttonWasClicked:)];

        [self addSubview:sub];

        [sortButtons addObject:sub];

        origin.x += [sub frameSize].width;
    }

    // add the gear button thingy
    optionsPopupButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0, 0, 45, kSortBarHeight)];

    [optionsPopupButton addItemWithTitle:nil];
    [[optionsPopupButton lastItem] setImage:resourcesImage("optionsgear.png",12, 13)];
    [optionsPopupButton setImagePosition:CPImageOnly];
    [optionsPopupButton setValue:CGInsetMake(0, 0, 0, 0) forThemeAttribute:"content-inset"];

    [optionsPopupButton setPullsDown:YES];
    [optionsPopupButton setBordered:NO];
    [self addSubview:optionsPopupButton];
    
}

- (void)buttonWasClicked:(id)sender
{
    // remove the images from all buttons
    [sortButtons makeObjectsPerformSelector:@selector(setImage:) withObjects:[blankImage]];
    [sortButtons makeObjectsPerformSelector:@selector(unsetThemeState:) withObjects:[CPThemeStateHighlighted]];

    [sortDescriptors removeObject:[sender sortDescriptor]];
    // toggle the sort descriptor
    [sender toggleSort];
    [sender setThemeState:CPThemeStateHighlighted];

    // move the sort descriptor to the front
    [sortDescriptors insertObject:[sender sortDescriptor] atIndex:0];

    // fire the delegate
    if ([delegate respondsToSelector:@selector(sortDescriptorsDidChange:)])
        [delegate sortDescriptorsDidChange:sortDescriptors];
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
    CPSortDescriptor sortDescriptor @accessors;
    CPImage          sortImageUp;
    CPImage          sortImageDown;
}

- (id)initWithTitle:(CPString)aTitle sortDescriptor:(CPSortDescriptor)aSortDescriptor
{
    self = [super initWithFrame:CGRectMake(0,0,100,24)];

    sortDescriptor = aSortDescriptor;

    [self setValue:[CPColor clearColor] forThemeAttribute:"bezel-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[resourcesImage("sortbar-active-left.png", 3, 35), resourcesImage("sortbar-active-center.png", 27, 36), resourcesImage("sortbar-active-right.png", 3, 36)] isVertical:NO]] forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];
    [self setValue:[CPColor colorWithRed:145/255 green:150/255 blue:153/255 alpha:1] forThemeAttribute:"text-color"];
    [self setValue:[CPColor whiteColor] forThemeAttribute:"text-shadow-color"];
    [self setValue:CGSizeMake(0,1) forThemeAttribute:"text-shadow-offset"];
    [self setFont:[CPFont boldSystemFontOfSize:11]];

    [self setTitle:aTitle];
    [self sizeToFit];

    sortImageUp = resourcesImage("FIXME_arrowup.png", 10, 10);
    sortImageDown = resourcesImage("FIXME_arrowdown.png", 10, 10);

    [self setImage:blankImage];
    [self setImagePosition:CPImageRight];

    var size = [self frameSize];

    size.width += 24;
    size.height = kSortBarHeight;
    [self setFrameSize:size];

    return self;
}

- (void)toggleSort
{
    var newDescriptor = [sortDescriptor reversedSortDescriptor];

    sortDescriptor = newDescriptor;

    if ([sortDescriptor ascending])
        [self setImage:sortImageUp];
    else
        [self setImage:sortImageDown];
}

@end