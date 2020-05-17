//
// Created by _kritanta on 5/7/20.
//

@import UIKit;

#include "CHPLabelDelegate.h"
#import "SpringBoardHome.h"

#ifndef CHPMANAGER_H
#define CHPMANAGER_H

@interface CHPManager : NSObject <CHPLabelDelegate>

- (instancetype)initWithDomain:(NSString *)domain;

- (void)relayoutIfNeeded;

- (void)reloadLabelsForRootFolderController:(SBRootFolderController *)controller index:(NSInteger)index;

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readwrite) NSMutableDictionary *labels;

@property (nonatomic, readonly) BOOL reloadNeeded;
@property (nonatomic, strong, readwrite) UIColor *labelColor;
@property (nonatomic, strong, readonly) NSUserDefaults *store;
@property (nonatomic, readwrite) struct SBIconListLayoutMetrics layoutMetrics;

@end

#endif //CHPMANAGER_H