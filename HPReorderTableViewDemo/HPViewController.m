//
//  HPViewController.m
//  HPReorderTableViewDemo
//
//  Created by Hermes on 22/01/14.
//  Copyright (c) 2014 Hermes Pique. All rights reserved.
//

#import "HPViewController.h"
#import "HPReorderTableView.h"

@interface HPViewController ()<UITableViewDataSource>

@end

@implementation HPViewController
{
    NSMutableArray *_objects;
    UITableView *_tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objects = [NSMutableArray array];
    for (int i = 0; i < 100; i++)
    {
        [_objects addObject:[NSString stringWithFormat:@"%d", i]];
    }
    _tableView = [[HPReorderTableView alloc] initWithFrame:self.view.bounds]; // Here is where the magic happens
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = _objects[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *source = _objects[sourceIndexPath.row];
    NSString *destination = _objects[destinationIndexPath.row];
    [_objects replaceObjectAtIndex:destinationIndexPath.row withObject:source];
    [_objects replaceObjectAtIndex:sourceIndexPath.row withObject:destination];
}

@end
