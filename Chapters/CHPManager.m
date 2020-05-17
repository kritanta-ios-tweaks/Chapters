//
// Created by _kritanta on 5/7/20.
//

#import "CHPManager.h"
#import "CHPPageLabelView.h"

@implementation CHPManager
{

@private
    NSUserDefaults *_store;
    UIColor *_labelColor;
}

@synthesize store = _store;
@synthesize labels = _labels;
@synthesize reloadNeeded = _reloadNeeded;

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedInstance = [[self alloc] initWithDomain:@"me.kritanta.chapters"];
    });

    return _sharedInstance;
}

- (instancetype)initWithDomain:(NSString *)domain
{
    self = [super init];

    if (self)
    {
        _store = [[NSUserDefaults alloc] initWithSuiteName:domain];
        _labels = [NSMutableDictionary new];

        _reloadNeeded = YES;
    }

    return self;
}

/**
 * Call `reload` on any labels we've rendered if a reload is needed.
 */
- (void)relayoutIfNeeded
{
    if (!_reloadNeeded)
    {
        return;
    }

    for (CHPPageLabelView *label in [_labels allValues])
    {
        [label reload];
    }
}

/**
 * @return A label color if one has been set, else white
 */
- (UIColor *)labelColor
{
    return _labelColor ?: [UIColor whiteColor];
}

/**
 * Set label color and indicate a reload is needed
 *
 * @param color Color that labels should update to.
 */
- (void)setLabelColor:(UIColor *)color
{
    _labelColor = color;
    _reloadNeeded = YES;
}

/**
 * Load/Reload labels for a given rootFolderController by iterating through added pages
 *      and inserting labels where _labels contains no object at that index
 *
 * @param controller SBRootFolderController that we're loading labels into
 * @param index Specific page index, -1 will reload all
 */
- (void)reloadLabelsForRootFolderController:(SBRootFolderController *)controller index:(NSInteger)index
{
    // Occasionally springboard throws an insanely high number at us
    // Rather than finding the source of this issue I've opted to just
    //      nix any index thrown at us higher than 500. It works.
    if (index >= 500)
    {
        return;
    }

    @try
    {
        struct SBIconListLayoutMetrics metrics;
        metrics.layoutInsets = [[[[controller folderDelegate] rootIconListAtIndex:0] layout]
                layoutInsetsForOrientation:1];

        _layoutMetrics = metrics;
    }
    @catch (NSException *ex)
    {
        return;
    }

    if (index != -1)
    {
        [[self labelForIndex:index onController:controller createIfNecessary:YES] reload];
    }

    for (int i = 0; i < [controller iconListViewCount]; i++)
    {
        if ([controller folderDelegate])
        {
            SBIconListView *list = [[controller folderDelegate] rootIconListAtIndex:i];
            if (list)
            {
                [[self labelForIndex:i onController:controller createIfNecessary:YES] reload];
            }
        }
    }
}

- (CHPPageLabelView *)labelForIndex:(NSInteger)index onController:(SBRootFolderController *)controller
                  createIfNecessary:(BOOL)create
{
    // Check if a value exists for the index we were given
    if (!_labels[@(index)] && create)
    {
        @try
        {
            // If not, create a label and assign it to that index
            CHPPageLabelView *label = [[CHPPageLabelView alloc] initWithPageIndex:index andLabelDelegate:self];

            // We add the view as a subview here. I'd like to move this to somewhere more
            //      pointed, but this works perfectly fine.
            [[[controller folderDelegate] rootIconListAtIndex:index] addSubview:label];
            _labels[@(index)] = label;
        }
        @catch (NSException *ex)
        {
            return nil;
        }
    }

    // Give the label for that index.
    return _labels[@(index)];
}

/**
 * Retrieve stored label text for a page
 *
 * @param index Index of page, starting at 0
 * @return NSString stored name for page index requested, Page ${index+1} if none exists
 */
- (NSString *)nameForPageIndex:(NSInteger)index
{
    return [_store objectForKey:[NSString stringWithFormat:@"%ld", (long)index]] ?: [NSString stringWithFormat:@"Page "
                                                                                                             "%ld",
                                                                                                  (long)index + 1];
}

/**
 * Set the stored value for a label
 *
 * @param name NSString Label text to store
 * @param index NSInteger index of the page starting at 0
 */
- (void)setName:(NSString *)name forPageIndex:(NSInteger)index
{
    [_store setObject:name forKey:[NSString stringWithFormat:@"%ld", (long)index]];
}

/**
 * Calculate the frame for a label based on layoutMetrics given.
 *
 * @return CGRect frame calculated
 */
- (CGRect)frameForLabel
{
    if (_layoutMetrics.layoutInsets.left == 0)
    {
        // If we don't have a proper rect, just assume iPhone X defaults.
        return CGRectMake(27, 54, [[UIScreen mainScreen] bounds].size.width - 54, 70);
    }

    return CGRectMake(_layoutMetrics.layoutInsets.left + 2, _layoutMetrics.layoutInsets.top - 10, [[UIScreen
            mainScreen] bounds].size.width - _layoutMetrics.layoutInsets.left * 2, 70);

}

@end