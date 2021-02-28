//
// Created by _kritanta on 5/7/20.
//

@import UIKit;

#include "CHPLabelDelegate.h"

#ifndef CHPPAGELABELVIEW_H
#define CHPPAGELABELVIEW_H

@interface CHPPageLabelView : UIView <UITextFieldDelegate>

@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, weak, readwrite) NSObject <CHPLabelDelegate> *labelDelegate;
@property (nonatomic, strong, readonly) NSString *realText;
@property (nonatomic, strong, readonly) UITextField *actualLabel;

- (instancetype)initWithPageIndex:(NSInteger)index andLabelDelegate:(NSObject <CHPLabelDelegate> *)labelDelegate;

- (void)reload;

@end

#endif //CHPPAGELABELVIEW_H
