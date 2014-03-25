UIImageView+PlayGIF
===================

<img src="https://raw.githubusercontent.com/yfme/UIImageView-PlayGIF/master/screenshot.gif" width="314px" style="width: 314px;" />

===================
UIImageView category for playing GIF. Simple, high perfomence, low memory footprint.

 *  Dependencies:
  *      `- QuartzCore.framework`
  *      `- ImageIO.framework`
 *  Parameters:
  *      Pass value to one of them:
  *      `- gifData` NSData from a GIF
  *      `- gifPath` local path of a GIF
 *  Usage:
  *      `- startGIF`
  *      `- stopGIF`
  *      `- isGIFPlaying`

===================
支持 GIF 播放的 UIImageView 类别。 简单，高效，低功耗。

 *  依赖:
  *      `- QuartzCore.framework`
  *      `- ImageIO.framework`
 *  参数:
  *      以下传参2选1：
  *      `- gifData`       GIF图片的NSData
  *      `- gifPath`       GIF图片的本地路径
 *  调用:
  *      `- startGIF`      开始播放
  *      `- stopGIF`       结束播放
  *      `- isGIFPlaying`  判断是否正在播放

=================== 
```objc
//
//  UIImageView+PlayGIF.h
//  UIImageView+PlayGIF
//
//  Created by Yang Fei on 14-3-25.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface UIImageView (PlayGIF)
@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
@property (nonatomic, strong) CADisplayLink     *displayLink;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
@end
```

