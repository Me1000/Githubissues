@implementation ISIssueDataView : CPView
{
    @outlet CPImageView avatarView;

    @outlet CPTextField titleField;
    @outlet CPTextField userField;
    @outlet CPTextField openedOnLabel;
    @outlet CPTextField openedOnField;
    @outlet CPTextField updatedLabel;
    @outlet CPTextField updatedField;
    @outlet CPImageView commentsIcon;
    @outlet CPTextField commentsField;
}

- (void)awakeFromCib
{
    var white = [CPColor whiteColor],
        offset = CGSizeMake(1,1);

    [titleField    setValue:white forThemeAttribute:"text-shadow-color"];
    [userField     setValue:white forThemeAttribute:"text-shadow-color"];
    [openedOnLabel setValue:white forThemeAttribute:"text-shadow-color"];
    [openedOnField setValue:white forThemeAttribute:"text-shadow-color"];
    [updatedLabel  setValue:white forThemeAttribute:"text-shadow-color"];
    [updatedField  setValue:white forThemeAttribute:"text-shadow-color"];
    [commentsIcon  setValue:white forThemeAttribute:"text-shadow-color"];
    [commentsField setValue:white forThemeAttribute:"text-shadow-color"];

    [titleField    setValue:offset forThemeAttribute:"text-shadow-offset"];
    [userField     setValue:offset forThemeAttribute:"text-shadow-offset"];
    [openedOnLabel setValue:offset forThemeAttribute:"text-shadow-offset"];
    [openedOnField setValue:offset forThemeAttribute:"text-shadow-offset"];
    [updatedLabel  setValue:offset forThemeAttribute:"text-shadow-offset"];
    [updatedField  setValue:offset forThemeAttribute:"text-shadow-offset"];
    [commentsIcon  setValue:offset forThemeAttribute:"text-shadow-offset"];
    [commentsField setValue:offset forThemeAttribute:"text-shadow-offset"];

    // Size to fit them here that way we don't have to do it in setObjectValue:
    // should make performance better while scrolling.

    [openedOnLabel sizeToFit];
    [updatedLabel sizeToFit];
}

- (void)setObjectValue:(id)aValue
{
//console.log(aValue);

    [avatarView setImage:resourcesImage("gravatar-140.png", 30, 30)];

    [titleField setStringValue:"#" + [aValue number] + " " + [aValue title]];
    [titleField sizeToFit];

    var user = [aValue user],
        name = [user valueForKey:"name"];

    if (!name || [name isEqual:[CPNull null]])
        name = [user valueForKey:"login"];

    [userField setStringValue:name];
    [userField sizeToFit];

    var point = [openedOnLabel frame].origin;
    point.x = CGRectGetMaxX([userField frame]) + 2;
    [openedOnLabel setFrameOrigin:point];

    point.x = CGRectGetMaxX([openedOnLabel frame]) + 2;
    [openedOnField setFrameOrigin:point];
    [openedOnField setStringValue:[[aValue createdAt] friendlyDateString]];
    [openedOnField sizeToFit];

    point.x = CGRectGetMaxX([openedOnField frame]) + 2;
    [updatedLabel setFrameOrigin:point];

    point.x = CGRectGetMaxX([updatedLabel frame]) + 2;
    [updatedField setFrameOrigin:point];
    [updatedField setStringValue:[[aValue updatedAt] friendlyDateString]];
    [updatedField sizeToFit];

    [commentsField setStringValue:[aValue numberOfComments] + " comments"];

    // FIX ME: what we could do is preload all the images by having the browser loop through all the issues, taking the submit
    // user image and just creating a new image object. Memory considerations should be ... herp ... considered though.
    [avatarView setImage:[[CPImage alloc] initWithContentsOfFile:[user objectForKey:"gravatar_url"] size:CGSizeMake(30, 30)]];
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:avatarView forKey:"avatarView"];
    [aCoder encodeObject:titleField    forKey:"titleField"];
    [aCoder encodeObject:userField     forKey:"userField"];
    [aCoder encodeObject:openedOnLabel forKey:"openedOnLabel"];
    [aCoder encodeObject:openedOnField forKey:"openedOnField"];
    [aCoder encodeObject:updatedLabel  forKey:"updatedLabel"];
    [aCoder encodeObject:updatedField  forKey:"updatedField"];
    [aCoder encodeObject:commentsIcon  forKey:"commentsIcon"];
    [aCoder encodeObject:commentsField forKey:"commentsField"];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    avatarView      = [aCoder decodeObjectForKey:"avatarView"];
    titleField      = [aCoder decodeObjectForKey:"titleField"];
    userField       = [aCoder decodeObjectForKey:"userField"];
    openedOnLabel   = [aCoder decodeObjectForKey:"openedOnLabel"];
    openedOnField   = [aCoder decodeObjectForKey:"openedOnField"];
    updatedLabel    = [aCoder decodeObjectForKey:"updatedLabel"];
    updatedField    = [aCoder decodeObjectForKey:"updatedField"];
    commentsIcon    = [aCoder decodeObjectForKey:"commentsIcon"];
    commentsField   = [aCoder decodeObjectForKey:"commentsField"];

    return self;
}

@end