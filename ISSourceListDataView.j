/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

/*!
    This data view is used to display nearly every item in the sidebar
    There are four components to the object value

    1. Image - Small image that represents the item
        this image can be a lock if it's a private repo or a tag/milestone/assignee
    2. Text - duh
    3. Number - The main number in the badge
    4. Special number - displayed in green with the
        badge. For now the only reason we have this is to show "assigned repos"
*/

var ISSourceLockImage       = nil,
    ISSourceLockImageActive = nil;

@implementation ISSourceListDataView : CPView
{
    @outlet CPImageView imageview;
    @outlet CPTextField textfield;
    ISAssignedBadgeView assignedBadgeView;
    ISOpenBadgeView     openBadgeView;

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

    assignedBadgeView = [[ISAssignedBadgeView alloc] initWithFrame:CGRectMake(0, 0, 0, 17)];
    [assignedBadgeView setAutoresizingMask:CPViewMinXMargin];
    [self addSubview:assignedBadgeView];

    openBadgeView = [[ISOpenBadgeView alloc] initWithFrame:CGRectMake(0, 0, 50, 17)];
    [openBadgeView setAutoresizingMask:CPViewMinXMargin];
    [self addSubview:openBadgeView];

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

    // Size to fit works automatically because the theme insets are correct.
    [assignedBadgeView sizeToFit];
    [openBadgeView sizeToFit];


    var beginingOfBadge = width - [assignedBadgeView bounds].size.width - [openBadgeView bounds].size.width - 3;
    [assignedBadgeView setFrame:CGRectMake(beginingOfBadge, 9, [assignedBadgeView bounds].size.width, 17)];

    [openBadgeView setFrameOrigin:CGPointMake(CGRectGetMaxX([assignedBadgeView frame]), 9)];

    [textfield setFrameSize:CGSizeMake(beginingOfBadge - inset, height)];
}

- (void)setObjectValue:(id)aValue
{
    var image = nil;
    if ([aValue isKindOfClass:ISRepository])
    {
        text = [aValue identifier];
        number = [aValue numberOfOpenIssues];
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
    else if (aValue)
    {
        text = aValue.text;
        number = aValue.number;
        specialNumber = aValue.specialNumber;
    }

    [textfield setStringValue:text];
    [imageview setImage:image];
    [assignedBadgeView setStringValue:specialNumber];
    [assignedBadgeView setHidden:!specialNumber];
    [openBadgeView setStringValue:number];
    [openBadgeView setIsClosed:!specialNumber];
    [openBadgeView setHidden:!number && !specialNumber];
}

- (void)setThemeState:(CPThemeState)aState
{
    [super setThemeState:aState];
    [textfield setThemeState:aState];
    [imageview setImage:[self hasThemeState:CPThemeStateSelectedDataView] ? selectedImage : image];
    [assignedBadgeView setThemeState:aState];
    [openBadgeView setThemeState:aState];
}

- (void)unsetThemeState:(CPThemeState)aState
{
    [super unsetThemeState:aState];
    [textfield unsetThemeState:aState];
    [imageview setImage:[self hasThemeState:CPThemeStateSelectedDataView] ? selectedImage : image];
    [assignedBadgeView unsetThemeState:aState];
    [openBadgeView unsetThemeState:aState];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    imageview = [aCoder decodeObjectForKey:"imageview"];
    textfield = [aCoder decodeObjectForKey:"textfield"];
    assignedBadgeView = [aCoder decodeObjectForKey:"assignedBadgeView"];
    openBadgeView = [aCoder decodeObjectForKey:"openBadgeView"];
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:imageview forKey:"imageview"];
    [aCoder encodeObject:textfield forKey:"textfield"];
    [aCoder encodeObject:assignedBadgeView forKey:"assignedBadgeView"];
    [aCoder encodeObject:openBadgeView forKey:"openBadgeView"];
}

@end

@implementation ISBadgeView : CPTextField

- (id)initWithFrame:aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        [self applyLook];
    }
    return self;
}

- (void)applyLook
{
    [self setBezeled:NO];
    [self setTextColor:[CPColor colorWithHexString:"F5F5F5"]];
    [self setTextShadowColor:[CPColor colorWithCSSString:@"rgba(0, 0, 0, 0.5)"]];
    [self setTextShadowOffset:CGSizeMake(0.0, 1.0)];
    [self setFont:[CPFont systemFontOfSize:11.0]];
    [self setVerticalAlignment:CPCenterVerticalTextAlignment];
    [self setAlignment:CPCenterTextAlignment];
}


- (void)setThemeState:(CPThemeState)aState
{
    [super setThemeState:aState];
    [self updateBackground];
}

- (void)unsetThemeState:(CPThemeState)aState
{
    [super unsetThemeState:aState];
    [self updateBackground];
}

- (void)updateBackground
{

}

@end

// Reuse these for optimal speed - we don't want one colour instance per row.
var ISAssignedBadgeViewBackgroundColor = nil,
    ISOpenBadgeViewBackgroundColor = nil,
    ISOpenBadgeViewClosedBackgroundColor = nil,
    ISAssignedBadgeActiveViewBackgroundColor = nil,
    ISOpenBadgeViewActiveBackgroundColor = nil,
    ISOpenBadgeViewActiveClosedBackgroundColor = nil;

@implementation ISAssignedBadgeView : ISBadgeView

- (void)applyLook
{
    [super applyLook];

    [self setValue:CGInsetMake(3.0, 5.0, 2.0, 7.0) forThemeAttribute:"content-inset"];

    if (!ISAssignedBadgeViewBackgroundColor)
    {
        ISAssignedBadgeViewBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("assigned-badge-left.png", 7, 17),
            resourcesImage("assigned-badge-middle.png", 1, 17),
            resourcesImage("assigned-badge-right.png", 1, 17)
        ] isVertical:NO]];

        ISAssignedBadgeActiveViewBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("assigned-badge-active-left.png", 7, 17),
            resourcesImage("assigned-badge-active-middle.png", 1, 17),
            resourcesImage("assigned-badge-active-right.png", 1, 17)
        ] isVertical:NO]];
    }

    [self setBackgroundColor:ISAssignedBadgeViewBackgroundColor];
}

- (void)updateBackground
{
    [self setBackgroundColor:[self hasThemeState:CPThemeStateSelectedDataView] ? ISAssignedBadgeActiveViewBackgroundColor : ISAssignedBadgeViewBackgroundColor];
}

@end

@implementation ISOpenBadgeView : ISBadgeView
{
    BOOL    isClosed @accessors;
}

- (void)applyLook
{
    [super applyLook];

    [self setValue:CGInsetMake(3.0, 6.0, 2.0, 6.0) forThemeAttribute:"content-inset"];

    if (!ISOpenBadgeViewBackgroundColor)
    {
        ISOpenBadgeViewBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("open-badge-left.png", 1, 17),
            resourcesImage("open-badge-middle.png", 1, 17),
            resourcesImage("open-badge-right.png", 7, 17)
        ] isVertical:NO]];

        ISOpenBadgeViewClosedBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("open-badge-closed-left.png", 7, 17),
            resourcesImage("open-badge-middle.png", 1, 17),
            resourcesImage("open-badge-right.png", 7, 17)
        ] isVertical:NO]];

        ISOpenBadgeActiveViewBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("open-badge-active-left.png", 1, 17),
            resourcesImage("open-badge-active-middle.png", 1, 17),
            resourcesImage("open-badge-active-right.png", 7, 17)
        ] isVertical:NO]];

        ISOpenBadgeActiveViewClosedBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
            resourcesImage("open-badge-closed-active-left.png", 7, 17),
            resourcesImage("open-badge-active-middle.png", 1, 17),
            resourcesImage("open-badge-active-right.png", 7, 17)
        ] isVertical:NO]];
    }

    [self setIsClosed:YES];
}

- (void)setIsClosed:(BOOL)aFlag
{
    isClosed = aFlag;
    [self updateBackground];
}

- (void)updateBackground
{
    [self setBackgroundColor:
        [self hasThemeState:CPThemeStateSelectedDataView] ?
            isClosed ? ISOpenBadgeActiveViewClosedBackgroundColor : ISOpenBadgeActiveViewBackgroundColor :
            isClosed ? ISOpenBadgeViewClosedBackgroundColor : ISOpenBadgeViewBackgroundColor];
}

@end