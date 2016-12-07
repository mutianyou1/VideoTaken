//
//  MUCaptureSession.m
//  视频通话
//
//  Created by mutianyou1 on 16/4/12.
//  Copyright © 2016年 mutianyou1. All rights reserved.
//

#import "MUCaptureSession.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MUCaptureSession(){
    AVCaptureDeviceInput *_videoInput;

}

@end
@implementation MUCaptureSession
- (void)startTakeVedioWithCarmeraIndex:(NSInteger)index{
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *videoDivice = deviceArray[index];
    //videoDivice.flashMode = AVCaptureFlashModeAuto;//闪光灯自动
    //videoDivice.focusMode = AVCaptureFocusModeAutoFocus;//聚焦自动
   // videoDivice.focusPointOfInterest = CGPointMake(20, 20);
    //[AVCaptureVideoDevice setFocusMode:] may not be called without first successfully
    [videoDivice lockForConfiguration:nil];
    [videoDivice setFlashMode:AVCaptureFlashModeAuto];
    [videoDivice unlockForConfiguration];
    
    
    //初始化摄像头
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDivice error:nil];
    
    
    //初始化麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
   
    //初始化输出
    if (!self.outPut) {
        self.outPut = [[AVCaptureMovieFileOutput alloc]init];
        self.captureSession = [[AVCaptureSession alloc]init];
    }
    self.zoomFactor = 1.00;
    [self.captureSession beginConfiguration];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }else{
        [self userReject];
    }
    
    
    //加入输入输出
    if ([self.captureSession canAddInput:_videoInput]) {
        [self.captureSession addInput:_videoInput];
    }else{
        [self userReject];
    }
    
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    }else{
        [self userReject];
    }
    
    if ([self.captureSession canAddOutput:_outPut]) {
        [self.captureSession addOutput:_outPut];
    }else{
        [self userReject];
    }

    

}

- (void)captureSessionRuning{
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

- (void)setFocus:(CGFloat)zommFactor{
    [self changeDeviceProperty:^(AVCaptureDevice *device) {
        [device rampToVideoZoomFactor:zommFactor withRate:10];
    }];
}
- (void)setFlashLigtMode:(AVCaptureFlashMode)flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *device) {
        device.flashMode = flashMode;
    }];
}
//更改属性必须锁住
- (void)changeDeviceProperty:(void(^)(AVCaptureDevice* device))propertyChanged{
    AVCaptureDevice *vedioDevie = [_videoInput device];
    [vedioDevie lockForConfiguration:nil];
    propertyChanged(vedioDevie);
    [_captureSession beginConfiguration];
    [vedioDevie unlockForConfiguration];
    [_captureSession commitConfiguration];
    
}
- (void)userReject{
    [self.MUCaptureSessionDelegate userRejectToAuthorization];
}
#pragma mark--AVCaptureFileOutputRecodingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
     __block NSURL *url = [outputFileURL copy];
    //captureOutput
    if (error == nil) {
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                
//                if (error) {
//                    NSLog(@"vedio wirte failed");
//                    url = nil;
//                }else{
//                    NSLog(@"开始导出%@",assetURL);
//                    url = [assetURL copy];
//                    [self compress];
//                }
//            }];
//        }
    }else{
        url = nil;
        NSLog(@"vedio write erro%@",error);
        
    }
    [self.MUCaptureSessionDelegate endRecodingPlayWithURL:url];
   
    

}
- (void)compress{



}
@end
