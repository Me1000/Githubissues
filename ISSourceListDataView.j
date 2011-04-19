/*!
    This data view is used to display nearly every item in the sidebar
    There are four components to the object value

    1. Image - Small image that represents the item
        this image can be a lock if it's a private repo or a tag/milestone/assignee
    2. Text - duh
    3. Number - The main number in the badge
    4. Special number - displayed in green with the
        badge. For now the only reason we have this is to show "assigmed repos"
*/

var ISSourceLockImage       = nil,
    ISSourceLockImageActive = nil;

@implementation ISSourceListDataView : CPView
{
    @outlet CPImageView imageview;
    @outlet CPTextField textfield;

    CPString    text;
    int         number;
    int         specialNumber;
    CPImage     image;
    CPImage     selectedImage;


    CPFont   cachedFont;
}
- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];

    cachedFont = [CPFont boldSystemFontOfSize:11];

    imageview = [[CPImageView alloc] initWithFrame:CGRectMake(5, 9, 15, 15)];
    [imageview setImageScaling:CPScaleNone];
    [self addSubview:imageview];

    textfield = [[CPTextField alloc] initWithFrame:CGRectMake(18, 9, 90, 15)];
    [textfield setFont:[CPFont boldSystemFontOfSize:11]];
    [textfield setLineBreakMode:CPLineBreakByTruncatingTail];
    [self addSubview:textfield];

    [textfield setValue:[CPColor colorWithRed:75/255 green:83/255 blue:89/255 alpha:1] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];
    [textfield setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.55] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [textfield setValue:CGSizeMake(0,1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];

    [textfield setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:1] forThemeAttribute:@"text-color" inState:CPThemeStateSelectedTableDataView];
    [textfield setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.25] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateSelectedTableDataView];

    return self;
}

- (void)layoutSubviews
{
    if (!cachedFont)
        cachedFont = [CPFont boldSystemFontOfSize:11];

    [super layoutSubviews];

    if (image)
        var origin = CGPointMake(18, 9);
    else
        var origin = CGPointMake(5, 9);

    [textfield setFrameOrigin:origin];


    // now find the inset of the textfield
    // console.log([specialNumber sizeWithFont:cachedFont], [number sizeWithFont:cachedFont]);
    var inset = 15,
        width = [self frameSize].width,
        height = [textfield frameSize].height;

    [textfield setFrameSize:CGSizeMake(width - origin.x - inset, height)];
}

- (void)drawRect:(CGRect)aRect
{
    // FIX ME:
    // add badge drawing
}

- (void)setObjectValue:(id)aValue
{
    var image = nil;
    if ([aValue isKindOfClass:ISRepository])
    {
        text = [aValue name];
        number = [aValue openIssues];
        specialNumber = [aValue issuesAssignedToCurrentUser];
        if ([aValue isPrivate])
        {
            if (!ISSourceLockImage)
                ISSourceLockImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"lock-icon.png"] size:CGSizeMake(8.0, 12.0)];
            image = ISSourceLockImage;

            if (!ISSourceLockImageActive)
                ISSourceLockImageActive = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"lock-icon-active.png"] size:CGSizeMake(8.0, 12.0)];
            selectedImage = ISSourceLockImageActive;
        }
    }
    else
    {
        text = aValue.text;
        number = aValue.number;
        specialNumber = aValue.specialNumber;
    }

    [textfield setStringValue:text];
    [imageview setImage:image];
}

- (void)setThemeState:(CPThemeState)aState
{
    [super setThemeState:aState];
    [textfield setThemeState:aState];
    [imageview setImage:[self hasThemeState:CPThemeStateSelectedDataView] ? selectedImage : image];
}

- (void)unsetThemeState:(CPThemeState)aState
{
    [super unsetThemeState:aState];
    [textfield unsetThemeState:aState];
    [imageview setImage:[self hasThemeState:CPThemeStateSelectedDataView] ? selectedImage : image];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    imageview = [aCoder decodeObjectForKey:"imageview"];
    textfield = [aCoder decodeObjectForKey:"textfield"];

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:imageview forKey:"imageview"];
    [aCoder encodeObject:textfield forKey:"textfield"];
}


@end