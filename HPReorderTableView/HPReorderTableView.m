
//
//  HPReorderTableView.m
//
//  Created by Hermes Pique on 22/01/14.
//  Copyright (c) 2014 Hermes Pique
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HPReorderTableView.h"

@interface HPReorderTableView(Subclassing)

@property (nonatomic, readonly) id<UITableViewDataSource> hp_realDataSource;

@end

@interface HPReorderTableView()<UITableViewDataSource>

@end

@implementation HPReorderTableView {
    UIImageView *_reorderDragView;
    __weak id<UITableViewDataSource> _realDataSource;
    NSIndexPath *_reorderInitialIndexPath;
    NSIndexPath *_reorderCurrentIndexPath;
    CADisplayLink *_scrollDisplayLink;
    CGFloat _scrollRate;
    CGFloat _reorderDragViewShadowOpacity;
}

static NSTimeInterval HPReorderTableViewAnimationDuration = 0.2;

static NSString *HPReorderTableViewCellReuseIdentifier = @"HPReorderTableViewCellReuseIdentifier";

@synthesize reorderDragView = _reorderDragView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initHelper];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    _reorderGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeLongPressGestureRecognizer:)];
    [self addGestureRecognizer:_reorderGestureRecognizer];
    
    _reorderDragView = [[UIImageView alloc] init];
    _reorderDragView.layer.shadowColor = [UIColor blackColor].CGColor;
    _reorderDragView.layer.shadowRadius = 2;
    _reorderDragView.layer.shadowOpacity = 0.5;
    _reorderDragView.layer.shadowOffset = CGSizeMake(0, 0);
    _reorderDragView.layer.masksToBounds = NO;
    
    // Data Source forwarding
    [super setDataSource:self];
    [self registerTemporaryEmptyCellClass:[UITableViewCell class]];
}

#pragma mark - Public

- (void)registerTemporaryEmptyCellClass:(Class)cellClass
{
    [self registerClass:cellClass forCellReuseIdentifier:HPReorderTableViewCellReuseIdentifier];
}

#pragma mark - Actions

- (void)recognizeLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (![self hasRows])
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self didBeginLongPressGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self didChangeLongPressGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self didEndLongPressGestureRecognizer:gestureRecognizer];
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_reorderCurrentIndexPath && [_reorderCurrentIndexPath compare:indexPath] == NSOrderedSame)
    {
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:HPReorderTableViewCellReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else
    {
        return [_realDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_realDataSource tableView:self numberOfRowsInSection:section];
}

#pragma mark - Data Source Forwarding

- (void)dealloc
{ // Data Source forwarding
    self.delegate = nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([_realDataSource respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:_realDataSource];
    }
    else
    {
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)s
{
    return [super methodSignatureForSelector:s] ?: [(id)_realDataSource methodSignatureForSelector:s];
}

- (BOOL)respondsToSelector:(SEL)s
{
    return [super respondsToSelector:s] || [_realDataSource respondsToSelector:s];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{ // Data Source forwarding
    [super setDataSource:dataSource ? self : nil];
    _realDataSource = dataSource != self ? dataSource : nil;
}

#pragma mark - Utils

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    return ![self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] || [self.dataSource tableView:self canMoveRowAtIndexPath:indexPath];
}

- (BOOL)hasRows
{
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger i = 0; i < sectionCount; i++)
    {
        if ([self numberOfRowsInSection:i] > 0) return YES;
    }
    return NO;
}

static UIImage* HPImageFromView(UIView *view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static void HPGestureRecognizerCancel(UIGestureRecognizer *gestureRecognizer)
{ // See: http://stackoverflow.com/a/4167471/143378
    gestureRecognizer.enabled = NO;
    gestureRecognizer.enabled = YES;
}

#pragma mark - Private

- (void)animateShadowOpacityFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(shadowOpacity))];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = HPReorderTableViewAnimationDuration;
    [_reorderDragView.layer addAnimation:animation forKey:NSStringFromSelector(@selector(shadowOpacity))];
    _reorderDragViewShadowOpacity = _reorderDragView.layer.shadowOpacity;
    _reorderDragView.layer.shadowOpacity = toValue;
}

- (void)didBeginLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    if (indexPath == nil || ![self canMoveRowAtIndexPath:indexPath])
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
    [cell setHighlighted:NO animated:NO];
    
    UIImage *image = HPImageFromView(cell);
    _reorderDragView.image = image;
    
    CGRect cellRect = [self rectForRowAtIndexPath:indexPath];
    _reorderDragView.frame = CGRectOffset(CGRectMake(0, 0, image.size.width, image.size.height), cellRect.origin.x, cellRect.origin.y);
    [self addSubview:_reorderDragView];
    if (_reorderDragView.layer.shadowOpacity == 0)
    {
        _reorderDragView.layer.shadowOpacity = _reorderDragViewShadowOpacity;
    }
    
    _reorderInitialIndexPath = indexPath;
    _reorderCurrentIndexPath = indexPath;
    
    [self animateShadowOpacityFromValue:0 toValue:_reorderDragView.layer.shadowOpacity];
    [UIView animateWithDuration:HPReorderTableViewAnimationDuration animations:^{
        _reorderDragView.center = CGPointMake(self.center.x, location.y);
    }];
    
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    _scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableWithCell:)];
    [_scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)didEndLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (!_reorderCurrentIndexPath)
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    NSIndexPath *indexPath = _reorderCurrentIndexPath;
    
    { // Reset
        [_scrollDisplayLink invalidate];
        _scrollDisplayLink = nil;
        _scrollRate = 0;
        _reorderCurrentIndexPath = nil;
        _reorderInitialIndexPath = nil;
    }
    
    [self animateShadowOpacityFromValue:_reorderDragView.layer.shadowOpacity toValue:0];
    
    [UIView animateWithDuration:HPReorderTableViewAnimationDuration
                     animations:^{
                         CGRect rect = [self rectForRowAtIndexPath:indexPath];
                         _reorderDragView.frame = CGRectOffset(_reorderDragView.bounds, rect.origin.x, rect.origin.y);
                     } completion:^(BOOL finished) {
                         [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                         [self performSelector:@selector(removeReorderDragView) withObject:nil afterDelay:0]; // Prevent flicker
                     }];
}

- (void)removeReorderDragView
{
    [_reorderDragView removeFromSuperview];
}

- (void)reorderCurrentRowToIndexPath:(NSIndexPath*)toIndexPath
{
    [self beginUpdates];
    [self moveRowAtIndexPath:toIndexPath toIndexPath:_reorderCurrentIndexPath]; // Order is important to keep the empty cell behind
    if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    {
        [self.dataSource tableView:self moveRowAtIndexPath:_reorderCurrentIndexPath toIndexPath:toIndexPath];
    }
    _reorderCurrentIndexPath = toIndexPath;
    [self endUpdates];
}

#pragma mark Subclassing

- (id<UITableViewDataSource>)hp_realDataSource
{
    return _realDataSource;
}

#pragma mark After BVReorderTableView
// Taken from https://github.com/bvogelzang/BVReorderTableView/blob/master/BVReorderTableView.m with minor modifications
//
//  BVReorderTableView.m
//
//  Copyright (c) 2013 Ben Vogelzang.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

- (void)didChangeLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self];
    
    // update position of the drag view
    // don't let it go past the top or the bottom too far
    if (location.y >= 0 && location.y <= self.contentSize.height + 50)
    {
        _reorderDragView.center = CGPointMake(self.center.x, location.y);
    }
    
    CGRect rect = self.bounds;
    // adjust rect for content inset as we will use it below for calculating scroll zones
    rect.size.height -= self.contentInset.top;
    
    [self updateCurrentLocation:gestureRecognizer];
    
    // tell us if we should scroll and which direction
    CGFloat scrollZoneHeight = rect.size.height / 6;
    CGFloat bottomScrollBeginning = self.contentOffset.y + self.contentInset.top + rect.size.height - scrollZoneHeight;
    CGFloat topScrollBeginning = self.contentOffset.y + self.contentInset.top  + scrollZoneHeight;
    
    // we're in the bottom zone
    if (location.y >= bottomScrollBeginning)
    {
        _scrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight;
    }
    // we're in the top zone
    else if (location.y <= topScrollBeginning)
    {
        _scrollRate = (location.y - topScrollBeginning) / scrollZoneHeight;
    }
    else
    {
        _scrollRate = 0;
    }
}

- (void)scrollTableWithCell:(NSTimer *)timer
{
    UILongPressGestureRecognizer *gesture = self.reorderGestureRecognizer;
    const CGPoint location = [gesture locationInView:self];
    
    CGPoint currentOffset = self.contentOffset;
    CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + _scrollRate * 10);
    
    if (newOffset.y < -self.contentInset.top)
    {
        newOffset.y = -self.contentInset.top;
    }
    else if (self.contentSize.height + self.contentInset.bottom < self.frame.size.height)
    {
        newOffset = currentOffset;
    }
    else if (newOffset.y > (self.contentSize.height + self.contentInset.bottom) - self.frame.size.height)
    {
        newOffset.y = (self.contentSize.height + self.contentInset.bottom) - self.frame.size.height;
    }
    
    [self setContentOffset:newOffset];
    
    if (location.y >= 0 && location.y <= self.contentSize.height + 50)
    {
        _reorderDragView.center = CGPointMake(self.center.x, location.y);
    }
    
    [self updateCurrentLocation:gesture];
}

- (void)updateCurrentLocation:(UILongPressGestureRecognizer *)gesture
{
    const CGPoint location  = [gesture locationInView:self];
    NSIndexPath *toIndexPath = [self indexPathForRowAtPoint:location];
    
    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
    {
        toIndexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:_reorderInitialIndexPath toProposedIndexPath:toIndexPath];
    }
    
    if ([toIndexPath compare:_reorderCurrentIndexPath] == NSOrderedSame) return;
    
    NSInteger originalHeight = _reorderDragView.frame.size.height;
    NSInteger toHeight = [self rectForRowAtIndexPath:toIndexPath].size.height;
    UITableViewCell *toCell = [self cellForRowAtIndexPath:toIndexPath];
    const CGPoint toCellLocation = [gesture locationInView:toCell];
    
    if (toCellLocation.y <= toHeight - originalHeight) return;
    
    [self reorderCurrentRowToIndexPath:toIndexPath];
}

@end

@implementation HPReorderAndSwipeToDeleteTableView

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.hp_realDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
    {
        return [self.hp_realDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end
