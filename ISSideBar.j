/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

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

            CPView        shadowOverlayViewTop;
            CPView        shadowOverlayViewRight;
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

    [col setDataView:[[ISSourceListDataView alloc] initWithFrame:CGRectMakeZero()]];

    [sourceList addTableColumn:col];
    [sourceList sizeLastColumnToFit];
    [sourceList setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
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

    var controller = [ISRepositoriesController sharedController];

    [sourceList setDataSource:controller];
    [sourceList setDelegate:controller];

    [controller setSourceList:sourceList];

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

    // FIXME Give this some other data.
    [filterList setDataSource:[ISRepositoriesController sharedController]];
    [filterListScrollView setDocumentView:filterList];

    var scroller = [[ISScroller alloc] initWithFrame:CGRectMake(0,0,10,10)];
    [filterListScrollView setVerticalScroller:scroller];

    shadowOverlayViewTop = [[CPView alloc] initWithFrame:CGRectMake(0, 0, [self bounds].size.width, 8)];
    var backgroundColor = [CPColor colorWithPatternImage:resourcesImage('sidebar-shadow-top.png', 1, 8)];
    [shadowOverlayViewTop setBackgroundColor:backgroundColor];
    [shadowOverlayViewTop setAutoresizingMask:CPViewWidthSizable];
    [self addSubview:shadowOverlayViewTop];

    shadowOverlayViewRight = [[CPView alloc] initWithFrame:CGRectMake([self bounds].size.width - 5, 0, 5, [self bounds].size.height)];
    backgroundColor = [CPColor colorWithPatternImage:resourcesImage('sidebar-shadow-right.png', 5, 1)];
    [shadowOverlayViewRight setBackgroundColor:backgroundColor];
    [shadowOverlayViewRight setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];
    [self addSubview:shadowOverlayViewRight];
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