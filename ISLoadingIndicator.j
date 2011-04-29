/*!
    ISLoadingIndicator is a sexy spinny thing.

    Created by Randy Luecke on April 28, 2011.
    Copyright 2011, RCLConcepts, LLC All rights reserved.
*/
@implementation ISLoadingIndicator : CPView
{
    CPTimer     spinnerTimer;
    CPImageView spinnerSprite;
    int         step;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];

    step = 0;
    spinnerSprite = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,358,29)];
    [spinnerSprite setImage:resourcesImage("spinnersprite.png", 358, 29)];
    [self addSubview:spinnerSprite];

    return self;
}

- (void)startAnimating
{
    spinnerTimer = [CPTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setNeedsLayout) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    [spinnerTimer invalidate]
}

- (void)layoutSubviews
{
    step++;

    if (step > 11)
        step = 0;

    [spinnerSprite setFrameOrigin:CGPointMake(step * (-30),0)];
}

@end