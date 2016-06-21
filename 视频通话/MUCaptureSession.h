//
//  MUCaptureSession.h
//  视频通话
//
//  Created by mutianyou1 on 16/4/12.
//  Copyright © 2016年 mutianyou1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MUCaptureSessionDelegate <NSObject>

- (void)userRejectToAuthorization;
- (void)endRecodingPlayWithURL:(NSURL*)url;
@end
@interface MUCaptureSession : NSObject <AVCaptureFileOutputRecordingDelegate>
@property (nonatomic,strong)AVCaptureSession *captureSession;
@property (nonatomic,strong)AVCaptureMovieFileOutput *outPut;
@property (nonatomic,assign)CGFloat zoomFactor;
@property (nonatomic,weak) id <MUCaptureSessionDelegate> MUCaptureSessionDelegate;
- (void)startTakeVedioWithCarmeraIndex:(NSInteger)index;
- (void)captureSessionRuning;
- (void)setFocus:(CGFloat)zommFactor;
- (void)setFlashLigtMode:(AVCaptureFlashMode)flashMode;
@end
