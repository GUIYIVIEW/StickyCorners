//
//  StickyCornersBehavior.h
//  StickyCorners
//
//  Created by Derek Carter on 3/8/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StickyCorner) {
    TopLeft = 0,
    BottomLeft,
    BottomRight,
    TopRight
};

@interface StickyCornersBehavior : UIDynamicBehavior

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) StickyCorner currentCorner;

- (instancetype)initWithItem:(id <UIDynamicItem>)item withCornerInset:(CGFloat)cornerInset;

- (void)updateFieldsInBounds:(CGRect)bounds;
- (void)addLinearVelocity:(CGPoint)velocity;
- (CGPoint)positionForCorner:(StickyCorner)corner;

@end