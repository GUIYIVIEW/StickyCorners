//
//  ViewController.m
//  StickyCorners
//
//  Created by Derek Carter on 3/8/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import "ViewController.h"
#import "StickyCornersBehavior.h"

@interface UIDynamicAnimator (AAPLDebugInterfaceOnly)
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;
@end

@interface ViewController ()
{
    UIView *_itemView;
    
    UIDynamicAnimator * _animator;
    StickyCornersBehavior *_stickyBehavior;
    
    CGPoint _offset;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create the itemView, add a pan gesture recognizer, then add the `itemView` as a subview of the viewController's view.
    _itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 90)];
    _itemView.backgroundColor = [UIColor blueColor];
    _itemView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [_itemView addGestureRecognizer:panGestureRecognizer];
    
    [self.view addSubview:_itemView];
    
    // Add a long press recognizer to toggle debugMode.
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
    // Create a UIDynamicAnimator.
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Create a StickyCornersBehavior with the itemView and a corner inset, then add it to the animator.
    _stickyBehavior = [[StickyCornersBehavior alloc] initWithItem:_itemView withCornerInset:30];
    [_animator addBehavior:_stickyBehavior];
    
    _offset = CGPointZero;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Ensure the item stays on screen during a bounds change.
    StickyCorner corner = _stickyBehavior.currentCorner;
    
    _stickyBehavior.isEnabled = NO;
    
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    [_stickyBehavior updateFieldsInBounds:bounds];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _itemView.center = [_stickyBehavior positionForCorner:corner];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _stickyBehavior.isEnabled = YES;
    }];
}


#pragma mark - UIGestureRecognizer Methods

- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        // Capture the initial touch offset from the itemView's center.
        CGPoint center = _itemView.center;
        _offset.x = location.x - center.x;
        _offset.y = location.y - center.y;
        
        // Disable the behavior while the item is manipulated by the pan recognizer.
        _stickyBehavior.isEnabled = NO;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        // Get reference bounds.
        CGRect referenceBounds = self.view.bounds;
        CGFloat referenceWidth = referenceBounds.size.width;
        CGFloat referenceHeight = referenceBounds.size.height;
        
        // Get item bounds.
        CGRect itemBounds = _itemView.bounds;
        CGFloat itemHalfWidth = itemBounds.size.width / 2.0;
        CGFloat itemHalfHeight = itemBounds.size.height / 2.0;
        
        // Apply the initial offset.
        location.x -= _offset.x;
        location.y -= _offset.y;
        
        // Bound the item position inside the reference view.
        location.x = MAX(itemHalfWidth, location.x);
        location.x = MIN(referenceWidth - itemHalfWidth, location.x);
        location.y = MAX(itemHalfHeight, location.y);
        location.y = MIN(referenceHeight - itemHalfHeight, location.y);
        
        // Apply the resulting item center.
        _itemView.center = location;
    }
    
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded) {
        // Get the current velocity of the item from the pan gesture recognizer.
        CGPoint velocity = [pan velocityInView:self.view];
        
        // Re-enable the stickyCornersBehavior.
        _stickyBehavior.isEnabled = YES;
        
        // Add the current velocity to the sticky corners behavior.
        [_stickyBehavior addLinearVelocity:velocity];
    }
}

- (void)longPress:(UIGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        _animator.debugEnabled = !_animator.debugEnabled;
    }
}

@end
