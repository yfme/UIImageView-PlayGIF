//
//  ViewController.m
//  UIImageView+PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import "ViewController.h"
#import "YFGIFImageView.h"
#import "UIImageView+PlayGIF.h"

@interface ViewController ()
@end

@implementation ViewController

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
    self.view.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, 320, 60)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Size: 1.8MB x 18";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    
    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"car.gif" ofType:nil]];
    for (int i=0; i<18; i++) {
        // user 'YFGIFImageView' or 'UIImageView+PlayGIF'
        YFGIFImageView *gifView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(8+i%3*(96+8), 28+i/3*(54+8), 96, 54)];
        //UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(8+i%3*(96+8), 28+i/3*(54+8), 96, 54)];
        gifView.backgroundColor = [UIColor darkGrayColor];
        gifView.gifData = gifData;
        [self.view addSubview:gifView];
        
        gifView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [gifView addGestureRecognizer:tap];
        [gifView startGIF];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
