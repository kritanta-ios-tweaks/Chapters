//
// Created by _kritanta on 5/7/20.
//

#import "CHPPageLabelView.h"


@implementation CHPPageLabelView
{

}

@synthesize index = _index;
@synthesize realText = _realText;
@synthesize labelDelegate = _labelDelegate;

/**
 * I'd like to see this expanded into some preference logic eventually, not
 *      everyone is a sucker for helvetica
 *
 * @return UIFont Font that should be used with the label
 */
+ (UIFont *)labelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0];
}

/**
 * Initialize with a specific index, and then pass that info
 *      to our labelDelegate and create our view there.
 *
 * @param index Page index starting at 0
 * @param labelDelegate class conforming to the CHPLabelDelegate protocol that provides information for us to use
 *                          when setting up our label view
 * @return CHPPageLabelView self
 */
- (instancetype)initWithPageIndex:(NSInteger)index andLabelDelegate:(NSObject <CHPLabelDelegate> *)labelDelegate
{
    self = [super init];

    if (self)
    {
        _index = index;
        _labelDelegate = labelDelegate;

        [self setFrame:[_labelDelegate frameForLabel]];

        _actualLabel = [[UITextField alloc] initWithFrame:[self bounds]];
        [self updateTextWithString:[_labelDelegate nameForPageIndex:index]];
        [_actualLabel setFont:[CHPPageLabelView labelFont]];
        [_actualLabel setDelegate:self];

        [self addSubview:_actualLabel];
    }

    return self;
}

/**
 * Called mainly by the controller of this view
 *
 * Should re-render anything graphical we might want to update
 */
- (void)reload
{
    self.frame = [_labelDelegate frameForLabel];
    [_actualLabel setTextColor:[_labelDelegate labelColor]];
}

- (void)updateTextWithString:(NSString *)string
{
    // TODO: process
    [_actualLabel setText:string];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

/**
 * Ensure we properly exit the text field and save our values
 *
 * @param textField UITextField self.actualLabel
 * @return BOOL yes
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    [_labelDelegate setName:[textField text] forPageIndex:_index];

    return YES;
}

@end