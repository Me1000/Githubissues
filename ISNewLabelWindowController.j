@import <AppKit/CPColorWell.j>

@implementation ISNewLabelWindowController : CPWindowController
{
    @outlet CPTextField errorField;
    @outlet CPTextField label;

    @outlet CPTextField nameField;
    @outlet CPColorWell colorButton;

    @outlet CPButton addButton;
    @outlet CPButton cancelButton;
}

- (void)awakeFromCib
{
    // FIX ME: WTFBBQ?!?! Nib2cib doesn't decode isEnabled properly? :/
    [colorButton setEnabled:YES];

    var win = [self window];

    [win setIsDetached:YES];
    [win styleButton:addButton withColor:"green"];
    [win styleButton:cancelButton withColor:"red"];
    [win styleTextField:nameField];
}

- (@action)addLabel:(id)sender
{
}

- (@action)cancel:(id)sender
{
    [[self window] orderOutWithAnimation:sender];
}


- (void)showWindow:(id)sender
{
    [[self window] setAnimationLocation:"50% 50%"];
    [[self window] setAnimationLength:"100"];

    [super showWindow:sender];
    [[self window] center];

    [[self window] orderFontWithAnimation:sender];
}
@end


var bezelColor = nil,
    highlightedBezelColor = nil;

@implementation CPColorWell (bezelstuff)

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort];

    if (self.isHighlighted)
    {
        gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [ 251 / 255, 251 / 255, 251 / 255, 1,
                                                                                        150 / 255, 150 / 255, 150 / 255, 1,
                                                                                        251 / 255, 251 / 255, 251 / 255, 1], [0, .1, 1], 3);
    }
    else
    {
        gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [ 251 / 255, 251 / 255, 251 / 255, 1,
                                                                                        200 / 255, 200 / 255, 200 / 255, 1,
                                                                                        251 / 255, 251 / 255, 251 / 255, 1], [0, .1, 1], 3);

    }


    var path = CGPathWithRoundedRectangleInRect(aRect, 3, 3, YES, YES, YES, YES);
    CGContextAddPath(context, path);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, aRect.size.height), nil);

}
- (void)drawBezelWithHighlight:(BOOL)shouldHighlight
{
    self.isHighlighted = shouldHighlight;
    [self setNeedsDisplay:YES];

    return;
    if (!bezelColor)
    {
        
        bezelColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
           [
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-left.png"] size:CGSizeMake(4.0, 24.0)],
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-center.png"] size:CGSizeMake(1.0, 24.0)],
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-right.png"] size:CGSizeMake(4.0, 24.0)]
            ]
        isVertical:NO]];
        
        highlightedBezelColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
            [
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-highlighted-left.png"] size:CGSizeMake(4.0, 24.0)],
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-highlighted-center.png"] size:CGSizeMake(1.0, 24.0)],
                [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleWithPath:@"Frameworks/AppKit/Resources/Aristo.blend"] pathForResource:@"button-bezel-highlighted-right.png"] size:CGSizeMake(4.0, 24.0)]
            ]
        isVertical:NO]];
    }

    var colorToUse = shouldHighlight ? highlightedBezelColor : bezelColor;

    [self setBackgroundColor:colorToUse];
}
@end