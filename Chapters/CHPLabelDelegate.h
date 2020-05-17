//
// Created by _kritanta on 5/7/20.
//

@import Foundation;

#ifndef CHPLABELDELEGATE_h
#define CHPLABELDELEGATE_h

@protocol CHPLabelDelegate <NSObject>

@property (nonatomic, strong, readwrite) UIColor *labelColor;

- (NSString *)nameForPageIndex:(NSInteger)index;

- (void)setName:(NSString *)name forPageIndex:(NSInteger)index;

- (CGRect)frameForLabel;

@end

#endif