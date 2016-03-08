//
//  StickyCornersBehavior.m
//  StickyCorners
//
//  Created by Derek Carter on 3/8/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import "StickyCornersBehavior.h"

@interface StickyCornersBehavior ()

@property (nonatomic, strong) id <UIDynamicItem> item;
@property (nonatomic) CGFloat cornerInset;

@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@property (nonatomic, strong) NSMutableArray *fieldBehaviors;

@end

@implementation StickyCornersBehavior

- (instancetype)initWithItem:(id <UIDynamicItem>)item withCornerInset:(CGFloat)cornerInset
{
    if (self = [super init]) {
        self.item = item;
        self.cornerInset = cornerInset;
        
        // Setup a collision behavior so the item cannot escape the screen.
        self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[item]];
        self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        
        // Setup the item behavior to alter the items physical properties causing it to be "sticky."
        self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        self.itemBehavior.density = 0.01;
        self.itemBehavior.resistance = 10;
        self.itemBehavior.friction = 0.0;
        self.itemBehavior.allowsRotation = NO;
        
        // Add each behavior as a child behavior.
        [self addChildBehavior:self.collisionBehavior];
        [self addChildBehavior:self.itemBehavior];
        
        // Setup a spring field behavior, one for each quadrant of the screen.
        // Then add each as a child behavior.
        self.fieldBehaviors = [NSMutableArray new];
        for (int i = 0; i < 4; i++) {
            UIFieldBehavior *fieldBehavior = [UIFieldBehavior springField];
            [fieldBehavior addItem:item];
            [self.fieldBehaviors addObject:fieldBehavior];
            [self addChildBehavior:fieldBehavior];
        }
    }
    return self;
}


#pragma mark - UIDynamicBehavior Methods

- (void)willMoveToAnimator:(UIDynamicAnimator *)dynamicAnimator
{
    [super willMoveToAnimator:dynamicAnimator];
    
    CGRect bounds = dynamicAnimator.referenceView.bounds;
    
    [self updateFieldsInBounds:bounds];
}


#pragma mark - Public Methods

- (void)updateFieldsInBounds:(CGRect)bounds
{
    if (!CGRectIsEmpty(bounds)) {
        CGRect itemBounds = self.item.bounds;
        
        // Determine the horizontal & vertical adjustment required to satisfy the cornerInset given the itemBounds.
        CGFloat dx = self.cornerInset + itemBounds.size.width / 2.0;
        CGFloat dy = self.cornerInset + itemBounds.size.height / 2.0;
        
        // Get bounds width & height.
        CGFloat h = bounds.size.height;
        CGFloat w = bounds.size.width;
        
        // Calculate the field origins.
        CGPoint topLeft = CGPointMake(dx, dy);
        CGPoint bottomLeft = CGPointMake(dx, h - dy);
        CGPoint bottomRight = CGPointMake(w - dx, h - dy);
        CGPoint topRight = CGPointMake(w - dx, dy);

        // Update each field.
        UIFieldBehavior *fieldBehaviorTopLeft = self.fieldBehaviors[TopLeft];
        fieldBehaviorTopLeft.position = topLeft;
        fieldBehaviorTopLeft.region = [[UIRegion alloc] initWithSize:CGSizeMake(w - (dx * 2), h - (dy * 2))];
        
        UIFieldBehavior *fieldBehaviorBottomLeft = self.fieldBehaviors[BottomLeft];
        fieldBehaviorBottomLeft.position = bottomLeft;
        fieldBehaviorBottomLeft.region = [[UIRegion alloc] initWithSize:CGSizeMake(w - (dx * 2), h - (dy * 2))];
        
        UIFieldBehavior *fieldBehaviorBottomRight = self.fieldBehaviors[BottomRight];
        fieldBehaviorBottomRight.position = bottomRight;
        fieldBehaviorBottomRight.region = [[UIRegion alloc] initWithSize:CGSizeMake(w - (dx * 2), h - (dy * 2))];
        
        UIFieldBehavior *fieldBehaviorTopRight = self.fieldBehaviors[TopRight];
        fieldBehaviorTopRight.position = topRight;
        fieldBehaviorTopRight.region = [[UIRegion alloc] initWithSize:CGSizeMake(w - (dx * 2), h - (dy * 2))];
    }
}

- (void)addLinearVelocity:(CGPoint)velocity
{
    [self.itemBehavior addLinearVelocity:velocity forItem:self.item];
}

- (CGPoint)positionForCorner:(StickyCorner)corner
{
    UIFieldBehavior *fieldBehavior = self.fieldBehaviors[corner];
    return fieldBehavior.position;
}

- (void)setIsEnabled:(BOOL)isEnabled
{
    if (isEnabled) {
        for (UIFieldBehavior *fieldBehavior in self.fieldBehaviors) {
            [fieldBehavior addItem:self.item];
        }
        [self.collisionBehavior addItem:self.item];
        [self.itemBehavior addItem:self.item];
    } else {
        for (UIFieldBehavior *fieldBehavior in self.fieldBehaviors) {
            [fieldBehavior removeItem:self.item];
        }
        [self.collisionBehavior removeItem:self.item];
        [self.itemBehavior removeItem:self.item];
    }
    
    _isEnabled = isEnabled;
}

- (StickyCorner)currentCorner
{
    if (self.dynamicAnimator) {
        //return nil;
    }
    
    CGPoint position = self.item.center;
    int index = 0;
    for (UIFieldBehavior *fieldBehavior in self.fieldBehaviors) {
        CGPoint fieldPosition = fieldBehavior.position;
        CGPoint location = CGPointMake(position.x - fieldPosition.x, position.y - fieldPosition.y);
        if ([fieldBehavior.region containsPoint:location]) {
            StickyCorner corner = (StickyCorner)index;
            return corner;
        }
        index++;
    }
    
    return 0;
}

@end