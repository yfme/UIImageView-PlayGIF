//
//  ViewController.m
//  UIImageView+PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+PlayGIF.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) UIImageView       *gifView;
@end

@implementation ViewController

- (IBAction)play:(id)sender {
    [_gifView startGIF];
}

- (IBAction)stop:(id)sender {
    [_gifView stopGIF];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"car.gif" ofType:nil]];
	UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 170)];
    gifView.center = self.view.center;
    gifView.gifData = gifData;
    [self.view addSubview:gifView];
    self.gifView = gifView;
    
    [self play:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
