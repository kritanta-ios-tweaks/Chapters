//
//  SpringBoardHome.h
//  Chapters
//
//  Created by _kritanta on 5/7/20.
//  Defines a few needed class types and structs available in SpringBoardHome.framework
//
@import UIKit;

#ifndef SpringBoardHome_h
#define SpringBoardHome_h

typedef struct SBIconCoordinate {
    NSInteger row;
    NSInteger col;
} SBIconCoordinate;

struct SBIconListLayoutMetrics {
    unsigned long long _field1;
    unsigned long long _field2;
    struct CGSize _field3;
    struct CGSize _field4;
    double _field5;
    struct UIEdgeInsets layoutInsets;
    _Bool _field7;
    _Bool _field8;
};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
@interface SBIconListFlowLayout : NSObject

- (UIEdgeInsets)layoutInsetsForOrientation:(NSInteger)orientation;

@end

@interface SBIconListView : UIView
-(void)layoutIconsNow;
@property (nonatomic, strong) SBIconListFlowLayout *layout;
@property (nonatomic, assign) NSUInteger firstFreeSlotIndex;
@property (readonly, nonatomic, getter=isFull) _Bool full;
@property (nonatomic, assign) NSInteger maximumIconCount;
@property (nonatomic, assign) NSInteger iconsInRowForSpacingCalculation;
@property (nonatomic, retain) NSArray *icons;
@property (nonatomic, retain) NSString *iconLocation;
@property (nonatomic,readonly) CGSize alignmentIconSize;
@end

@protocol SBRootFolderControllerDelegate

@end

@interface SBHIconManager <SBRootFolderControllerDelegate> : NSObject
- (SBIconListView *)rootIconListAtIndex:(long long)arg1;
- (NSInteger)currentIconListIndex;
@end

@interface SBIconListView (SBHIconManager)
@property (nonatomic, weak, readwrite) SBHIconManager *iconViewProvider;
@property (nonatomic, assign) UIEdgeInsets additionalLayoutInsets API_AVAILABLE(ios(14));
@end
@interface SBRootIconListView : SBIconListView
@end

@interface SBRootFolderController
@property (nonatomic, weak, readwrite) SBHIconManager<SBRootFolderControllerDelegate> *folderDelegate;
@property (nonatomic, assign) NSInteger iconListViewCount;
@end

@interface SBHIconManager (SBRootFolderController)
@property (nonatomic, strong,readwrite) SBRootFolderController *rootFolderController;
-(SBRootFolderController *) _rootFolderController;
@end

@interface SBIconController
@property (nonatomic, strong) SBHIconManager *iconManager;
+(instancetype) sharedInstance;
@end

@interface SBHomeScreenPreviewView : UIView

@end

#endif /* SpringBoardHome_h */
#pragma clang diagnostic pop