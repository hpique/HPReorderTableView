//
//  HPReorderTableView.h
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

#import <UIKit/UIKit.h>

@interface HPReorderTableView : UITableView

/** Set enabled to NO to disable reordering functionality. You can also provide a UIGestureRecognizerDelegate and implement gestureRecognizerShouldBegin:. 
 If you need to limit the area in which touches can trigger reordering, implement gestureRecognizer:shouldReceiveTouch:.
 */
@property (nonatomic, readonly) UILongPressGestureRecognizer *reorderGestureRecognizer;

/**
 To configure the appearence of the drag view (e.g., its shadow properties).
 */
@property (nonatomic, readonly) UIView *reorderDragView;

/**
 Provide your UITableViewCell subclass to set the appeareance of the temporary empty cell during dragging. An empty UITableViewCell is used by default, which leaves the empty space white.
 */
- (void)registerTemporaryEmptyCellClass:(Class)cellClass;

@end
