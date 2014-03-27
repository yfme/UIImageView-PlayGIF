UIImageView-PlayGIF
===================

<img src="https://raw.githubusercontent.com/yfme/UIImageView-PlayGIF/master/screenshot1.gif" width="200px" style="width: 200px;" />

===================
UIImageView category/subclass for playing GIF. Simple, high performance, low memory footprint.

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
 *  P.S.
  *      Don't like category? Use YFGIFImageView.h/m

===================
支持 GIF 播放的 UIImageView 类别或继承。 简单，高效，低功耗。

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
 *  另外:
  *      不想用 category？请使用 YFGIFImageView.h/m

=================== 
```objc
//
//  UIImageView+PlayGIF.h
//  UIImageView-PlayGIF
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
@property (nonatomic, strong) NSNumber          *index,*frameCount,*timestamp;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
@end
```
```objc
//
//  YFGIFImageView.h
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-26.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface YFGIFImageView : UIImageView
@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
@end
```

## License

UIImageView-PlayGIF is available under the MIT license. See the LICENSE file for more info.

