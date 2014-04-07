//
//  TableViewController.m
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-4-7.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import "TableViewController.h"
#import "UIImageView+PlayGIF.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"UIImageView-PlayGIF";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 114, 81)];
        gifView.backgroundColor = [UIColor darkGrayColor];
        gifView.tag = 100;
        [cell.contentView addSubview:gifView];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"index = %li",(long)indexPath.row];

    UIImageView *gifView = (UIImageView *)[cell.contentView viewWithTag:100];
    gifView.gifPath = [[NSBundle mainBundle] pathForResource:@"car.gif" ofType:nil];
    [gifView startGIF];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 81+20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
