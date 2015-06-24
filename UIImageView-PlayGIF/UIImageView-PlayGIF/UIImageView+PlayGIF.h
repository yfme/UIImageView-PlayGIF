//
//  UIImageView+PlayGIF.h
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

/*******************************************************
 *  Dependencies:
 *      - QuartzCore.framework
 *      - ImageIO.framework
 *  Parameters:
 *      Pass value to one of them:
 *      - gifData NSData from a GIF
 *      - gifPath local path of a GIF
 *  Usage:
 *      - startGIF
 *      - stopGIF
 *      - isGIFPlaying
 *  P.S.:
 *      Don't like category? Use YFGIFImageView.h/m
 *******************************************************/

/*******************************************************
 *  依赖:
 *      - QuartzCore.framework
 *      - ImageIO.framework
 *  参数:
 *      以下传参2选1：
 *      - gifData       GIF图片的NSData
 *      - gifPath       GIF图片的本地路径
 *  调用:
 *      - startGIF      开始播放
 *      - stopGIF       结束播放
 *      - isGIFPlaying  判断是否正在播放
 *  另外：
 *      不想用 category？请使用 YFGIFImageView.h/m
 *******************************************************/

#import <UIKit/UIImageView.h>

@interface UIImageView (PlayGIF)
@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
@property (nonatomic, strong) NSNumber          *index,*frameCount,*timestamp;
@property (nonatomic, strong) NSDictionary      *indexDurations;
- (void)startGIF;
- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
- (CGSize) gifPixelSize;
- (CGImageRef) gifCreateImageForFrameAtIndex:(NSInteger)index;
- (float)gifFrameDurationAtIndex:(size_t)index;
- (NSArray*)frames;
@end
