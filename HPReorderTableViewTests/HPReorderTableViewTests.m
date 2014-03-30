//
//  HPReorderTableViewTests.m
//  HPReorderTableViewTests
//
//  Created by Hermes on 22/01/14.
//  Copyright (c) 2014 Hermes Pique. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HPReorderTableView.h"

@interface HPReorderTableViewTests : XCTestCase

@end

@implementation HPReorderTableViewTests {
    HPReorderTableView *_tableView;
}

- (void)setUp
{
    [super setUp];
    _tableView = [HPReorderTableView new];
}


- (void)testInitWithFrameStyle
{
    HPReorderTableView *tableView = [[HPReorderTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    XCTAssertNotNil(tableView.reorderGestureRecognizer, @"");
    XCTAssertNotNil(tableView.reorderDragView, @"");
}

- (void)testInitWithFrame
{
    HPReorderTableView *tableView = [[HPReorderTableView alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(tableView.reorderGestureRecognizer, @"");
    XCTAssertNotNil(tableView.reorderDragView, @"");
}

- (void)testInitWithCoder
{
    NSCoder *coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData new]];
    HPReorderTableView *tableView = [[HPReorderTableView alloc] initWithCoder:coder];
    XCTAssertNotNil(tableView.reorderGestureRecognizer, @"");
    XCTAssertNotNil(tableView.reorderDragView, @"");
}

- (void)testRegisterTemporaryEmptyCellClass
{
    [_tableView registerTemporaryEmptyCellClass:UITableViewCell.class];
}


@end
