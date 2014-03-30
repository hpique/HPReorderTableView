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
    [self loadData];

    _tableView = [[HPReorderTableView alloc] initWithFrame:self.view.bounds]; // Here is where the magic happens
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *object = _objects[indexPath.row];
    cell.textLabel.text = object[0];
    cell.contentView.backgroundColor = object[1];
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [_objects exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

#pragma mark Utils

- (void)loadData
{
    _objects = [NSMutableArray array];
    for (int i = 0; i < 100; i++)
    {
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Cell %d", @""), i + 1];
        UIColor *color = [self.class cuasiRandomColor];
        [_objects addObject:@[text, color]];
    }
}

+ (UIColor*)cuasiRandomColor
{
    float r = arc4random() % 72;
    return [UIColor colorWithHue:(5*r)/360 saturation:0.2f brightness:1.0f alpha:1.0f];
}

@end
