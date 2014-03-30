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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    XCTAssertNotNil(tableView.panGestureRecognizer, @"");
}

- (void)testInitWithFrame
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(tableView.panGestureRecognizer, @"");
}

- (void)testInitWithCoder
{
    NSCoder *coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData new]];
    UITableView *tableView = [[UITableView alloc] initWithCoder:coder];
    XCTAssertNotNil(tableView.panGestureRecognizer, @"");
}


@end
