//
//  ViewController.m
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import "YFGIFImageView.h"
#import "UIImageView+PlayGIF.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)rightItemClicked:(id)sender{
    TableViewController *vc = [[TableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tapped:(UITapGestureRecognizer *)gestureRecognizer {
    YFGIFImageView *gifView = (YFGIFImageView *)gestureRecognizer.view;
    if (gifView.isGIFPlaying) {
        [gifView stopGIF];
    }else{
        [gifView startGIF];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"UIImageView-PlayGIF";
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightItemClicked:)];
    
    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"car.gif" ofType:nil]];
    for (int i=0; i<18; i++) {
        // user 'YFGIFImageView' or 'UIImageView+PlayGIF'
        YFGIFImageView *gifView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(8+i%3*(96+8), 64+28+i/3*(54+8), 96, 54)];
        //UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(8+i%3*(96+8), 28+i/3*(54+8), 96, 54)];
        gifView.backgroundColor = [UIColor darkGrayColor];
        gifView.gifData = gifData;
        [self.view addSubview:gifView];
        // notice: before start, content is nil. You can set image for yourself
        [gifView startGIF];
        
        gifView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [gifView addGestureRecognizer:tap];
	}
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, 320, 60)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Size: 1.8MB x 18";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
