/*!
    ISSideBar is just a simple sidebar with a sexy background
*/
@implementation ISSideBar : CPView
{
    @outlet ISAccountView accountView;
    @outlet CPView        reposHeader;
    @outlet CPView        filterHeaders;

    @outlet CPTextField   reposHeaderText;
    @outlet CPTextField   filtersHeaderText;

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

    [filtersHeaderText setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.5] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [filtersHeaderText setValue:CGSizeMake(0,1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];


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

    var col = [[CPTableColumn alloc] initWithIdentifier:@"Repositories"];

    // FIX ME: do this
    // [col setDataView:];

    [sourceList addTableColumn:col];
    [sourceList setHeaderView:nil];
    [sourceList setCornerView:nil];
    [sourceList setBackgroundColor:nil];
    [sourceList setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];

    [sourceList setDataSource:[ISRepositoriesController sharedController]];
    [sourceListScrollView setDocumentView:sourceList];


    // setup the filter list:
    // setup the source list
    filterList = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];

    var col = [[CPTableColumn alloc] initWithIdentifier:@"FilterList"];

    // FIX ME: do this
    // [col setDataView:];

    [filterList addTableColumn:col];
    [filterList setHeaderView:nil];
    [filterList setCornerView:nil];
    [filterList setBackgroundColor:nil];
    [filterList setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];

    [filterList setDataSource:[ISRepositoriesController sharedController]];
    [filterListScrollView setDocumentView:filterList];
}

- (void)drawRect:(CGRect)aRect
{
    // FIX ME: this isn't working
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [0, 0, 0, 0, /*2nd:*/ 0, 0, 0, 1], [0,1], 2);

    CGContextDrawLinearGradient(context, gradient, CGPointMake(aRect.size.width -3, 0), CGPointMake(aRect.size.width, 0), nil);
}
@end
