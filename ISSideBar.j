/*!
    ISSideBar is just a simple sidebar with a sexy background
*/
@implementation ISSideBar : CPView
{
    @outlet ISAccountView accountView;
    @outlet CPView        reposHeader;
    @outlet CPView        filterHeaders;

    @outlet CPTextField   reposHeaderText;
    @outlet ISHoverButton filtersHeaderText;

    @outlet CPButton      addRepoButton;
    @outlet CPButton      removeRepoButton;

            CPTableView   sourceList;
    @outlet CPScrollView  sourceListScrollView;


            CPTableView   filterList;
    @outlet CPScrollView  filterListScrollView;
}
- (void)awakeFromCib
{
    [self setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("SidebarTexture.png", 101, 84)]];

    [reposHeader   setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("SidebarHeaderBG.png", 42, 38)]];
    [filterHeaders setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("SidebarHeaderBG.png", 42, 38)]];

    [reposHeaderText setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.5] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [reposHeaderText setValue:CGSizeMake(0,1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];


    [addRepoButton setValue:[CPColor colorWithPatternImage:resourcesImage("plus.png", 31, 38)] forThemeAttribute:"bezel-color" inState:CPThemeStateNormal];
    [addRepoButton setValue:[CPColor colorWithPatternImage:resourcesImage("plus-active.png", 31, 38)] forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];

    [removeRepoButton setValue:[CPColor colorWithPatternImage:resourcesImage("minus.png", 33, 38)] forThemeAttribute:"bezel-color" inState:CPThemeStateNormal];
    [removeRepoButton setValue:[CPColor colorWithPatternImage:resourcesImage("minus-active.png", 33, 38)] forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];

    var frame = [removeRepoButton frame];
    frame.origin.y = 0;
    frame.size.height = 38;
    [removeRepoButton setFrame:frame];

    var frame = [addRepoButton frame];
    frame.origin.y = 0;
    frame.size.height = 38;
    [addRepoButton setFrame:frame];


    // setup the source list
    sourceList = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];

    var col = [[CPTableColumn alloc] initWithIdentifier:"Repositories"];

    // FIX ME: do this
     [col setDataView:[[ISSourceListDataView alloc] initWithFrame:CGRectMakeZero()]];

    [sourceList addTableColumn:col];
    [sourceList setHeaderView:nil];
    [sourceList setCornerView:nil];
    [sourceList setBackgroundColor:nil];
    [sourceList setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
    [sourceList setRowHeight:31];

    var sourceListSelectionColor = [CPDictionary dictionaryWithObjects: [CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [107/255, 141/255, 165/255, 1, /*2nd*/ 55/255, 87/255, 122/255, 1], [0,1], 2),
                                                                          [CPColor colorWithCalibratedRed:84/255 green:117/255 blue:140/255 alpha:1],
                                                                          [CPColor colorWithCalibratedRed:58/255 green:76/255 blue:89/255 alpha:1]
                                                                        ]
                                                               forKeys: [CPSourceListGradient, CPSourceListTopLineColor, CPSourceListBottomLineColor]]

    [sourceList setDataSource:[ISRepositoriesController sharedController]];
    [sourceListScrollView setDocumentView:sourceList];
    [sourceList setSelectionGradientColors:sourceListSelectionColor];


    // setup the filter list:
    // setup the source list
    filterList = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];

    var col = [[CPTableColumn alloc] initWithIdentifier:"FilterList"];

    // FIX ME: do this
    // [col setDataView:];

    [filterList addTableColumn:col];
    [filterList setHeaderView:nil];
    [filterList setCornerView:nil];
    [filterList setBackgroundColor:nil];
    [filterList setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
    [filterList setRowHeight:31];

    [filterList setDataSource:[ISRepositoriesController sharedController]];
    [filterListScrollView setDocumentView:filterList];

    var scroller = [[ISScroller alloc] initWithFrame:CGRectMake(0,0,10,10)];
    [filterListScrollView setVerticalScroller:scroller];
}

- (void)drawRect:(CGRect)aRect
{
    // FIX ME: this isn't working
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [0, 0, 0, 0, /*2nd:*/ 0, 0, 0, 1], [0,1], 2);

    CGContextDrawLinearGradient(context, gradient, CGPointMake(aRect.size.width -3, 0), CGPointMake(aRect.size.width, 0), nil);
}
@end


/*!
    FIX ME: Do something to make this prettier...
    Subclass may be a bad idea. Originally I was going to have
    a hover behaviour, but now I'm not so sure...
*/
@implementation ISHoverButton : CPPopUpButton

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];
    [self setAlignment:CPLeftTextAlignment];
    [self setValue:[CPColor colorWithRed:87/255 green:96/255 blue:102/255 alpha:1] forThemeAttribute:"text-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.5] forThemeAttribute:"text-shadow-color" inState:CPThemeStateNormal];
    [self setValue:CGSizeMake(0,1) forThemeAttribute:"text-shadow-offset" inState:CPThemeStateNormal];
    [self setBordered:NO];

    return self;
}

@end