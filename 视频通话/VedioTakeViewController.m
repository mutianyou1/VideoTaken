//
//  VedioTakeViewController.m
//  视频通话
//
//  Created by mutianyou1 on 16/4/11.
//  Copyright © 2016年 mutianyou1. All rights reserved.
//

#import "VedioTakeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "MUCaptureSession.h"
#import "PostVideoViewController.h"
@interface VedioTakeViewController ()<MUCaptureSessionDelegate,UIAlertViewDelegate>{
    UIButton *_cancelButton;
    UIButton *_chooseCamera;
    UIButton *_backButton;
    UIButton *_flashButton;
    UIButton *_focusButton;
    UILabel *_timeCount;
    NSDateFormatter *_formatter;
    NSTimer *_timer;
    NSDate *_date;
    BOOL _isBackCamera;
    BOOL _isBigScale;
    CGFloat _zommFactor;
    NSInteger _seconds;
    MUCaptureSession *_MucaptureSession;
    AVCaptureVideoPreviewLayer *_layer;
}
@property (nonatomic,strong)AVCaptureSession *captureSession;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic,strong)AVAssetWriter *assetWriter;
@property (nonatomic,strong)AVCaptureVideoDataOutput *videoOutPut;
@property (nonatomic,strong)AVCaptureAudioDataOutput *audioOutPut;
@property (nonatomic,strong)AVCaptureMovieFileOutput *outPut;
@end

@implementation VedioTakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拍摄视频";
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _isBigScale = YES;
    [self addButtons];
    [self startRecording:0];

}
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    //不需要时关掉
    [_MucaptureSession.captureSession stopRunning];
    [super viewWillDisappear:animated];
}

- (void)addButtons{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4];
    //headerView.alpha = 0.3;
    headerView.frame = CGRectMake(0, 0, WIDTH, 50);
    //[self.view addSubview:headerView];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.3];
    //bottomView.alpha = 0.5;
    bottomView.frame = CGRectMake(0, HEIGTH - 64, WIDTH, 64);
    //[self.view addSubview:bottomView];
    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton addTarget:self action:@selector(clickStart:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setTitle:@"◉" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:35];
    _cancelButton.frame = CGRectMake(WIDTH * 0.5 - 32, HEIGTH - 64,  64, 64);
    [self.view addSubview:_cancelButton];
    
    _focusButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _focusButton.exclusiveTouch = NO;
    [_focusButton addTarget:self action:@selector(clickChangeFocus:) forControlEvents:UIControlEventTouchUpInside];
    [_focusButton setTitle:@"+" forState:UIControlStateNormal];
    _focusButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _focusButton.frame = CGRectMake(WIDTH  - 64, HEIGTH - 64,  64, 64);
    _zommFactor = 1.0;
    [self.view addSubview:_focusButton];
    
    
    _chooseCamera = [UIButton buttonWithType:UIButtonTypeSystem];
    [_chooseCamera addTarget:self action:@selector(clickChooseCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_chooseCamera setTitle:@"♺" forState:UIControlStateNormal];
    _isBackCamera = YES;
    _chooseCamera.titleLabel.font = [UIFont systemFontOfSize:20];
    _chooseCamera.frame = CGRectMake(WIDTH - 110, 10, 100, 54);
    [self.view addSubview:_chooseCamera];

    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setTitle:@"取消" forState:UIControlStateNormal];
    _backButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _backButton.titleLabel.textColor = [UIColor whiteColor];
    _backButton.frame = CGRectMake(10, HEIGTH - 64, 50, 64);
    [self.view addSubview:_backButton];
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashButton addTarget:self action:@selector(clickOpenFlash:) forControlEvents:UIControlEventTouchUpInside];
    [_flashButton setTitle:@"⚡︎" forState:UIControlStateNormal];
    _flashButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _flashButton.titleLabel.textColor = [UIColor whiteColor];
    _flashButton.frame = CGRectMake(10,10, 50, 64);
    [self.view addSubview:_flashButton];
    
    
    _timeCount = [[UILabel alloc]init];
    _timeCount.frame = CGRectMake(WIDTH * 0.5 - 80, 10, 160, 54);
    _timeCount.textAlignment = NSTextAlignmentCenter;
    _timeCount.text = @"00:30";
    _timeCount.textColor = [UIColor whiteColor];
    _seconds = 30;
    [self.view addSubview:_timeCount];
    _formatter = [[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"mm:ss"];
}

- (void)clickBack:(UIButton*)button{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)startRecording:(NSInteger)carmeraIndex{
    _MucaptureSession = [[MUCaptureSession alloc]init];
    _MucaptureSession.MUCaptureSessionDelegate = self;
    [_MucaptureSession startTakeVedioWithCarmeraIndex:carmeraIndex];
    //创建预览涂层
    [_layer removeFromSuperlayer];
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    
    _layer = [AVCaptureVideoPreviewLayer layerWithSession:_MucaptureSession.captureSession];
    _layer.frame = CGRectMake(0, 74, WIDTH, HEIGTH - 134);
    _layer.masksToBounds = YES;
    _layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_layer];
    [_MucaptureSession captureSessionRuning];


}
- (void)startTakeVideo:(NSInteger)cameraIndex{
//    NSError *error = nil;
//    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    
//    //初始化摄像头
//    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:deviceArray[cameraIndex] error:&error];
//    //麦克风
//    AVCaptureDevice *device2 = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    AVCaptureDeviceInput *audioInput2 = [AVCaptureDeviceInput deviceInputWithDevice:device2 error:&error];
//    
//    //输出
//    self.outPut  = [[AVCaptureMovieFileOutput alloc]init];
//    
//    //初始化session
//    _captureSession = [[AVCaptureSession alloc]init];
//    [_captureSession beginConfiguration];
//    [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    //初始化视频写入
   // [self initVideoWriter];
    
//    //设备开启 默认设备
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
// 
//    
//   
//   //输出
//    _videoOutPut = [[AVCaptureVideoDataOutput alloc]init];
//    [_videoOutPut setAlwaysDiscardsLateVideoFrames:YES];
//    [_videoOutPut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//    [_videoOutPut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

}
- (void)clickStart:(UIButton*)button{
    if ([button.titleLabel.text containsString:@"◉"]) {
          [_cancelButton setTitle:@"◎" forState:UIControlStateNormal];
        _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFire) userInfo:nil repeats:YES];
       // NSString *betaPaht = [NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVedio.mov"];
       // NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:@"myMove.mov"];
        NSURL *url = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"compressed.mp4"]]];
        [_MucaptureSession.outPut startRecordingToOutputFileURL:url recordingDelegate:_MucaptureSession];
    }else{
    [_timer invalidate];
    [_MucaptureSession.outPut stopRecording];
    [_cancelButton setTitle:@"◉" forState:UIControlStateNormal];
   
    
    }
}
- (void)timeFire{
    _seconds --;
    _date = [NSDate dateWithTimeIntervalSince1970:_seconds];
    _timeCount.text = [_formatter stringFromDate:_date];
    if ([_timeCount.text isEqualToString:@"00:00"]) {
        _seconds = 30;
        _timeCount.text = @"00:30";
        [_cancelButton setTitle:@"◉" forState:UIControlStateNormal];
        [_timer invalidate];
        [_MucaptureSession.outPut stopRecording];
    }
}
- (void)clickChooseCamera:(UIButton*)button{
    //button.selected = !button.selected;
    _zommFactor = 1.0;
    if (_isBackCamera == YES) {
        _isBackCamera = NO;
        //[_chooseCamera setTitle:@"♺" forState:UIControlStateNormal];
        [self startRecording:1];
    }else{
        _isBackCamera = YES;
        //[_chooseCamera setTitle:@"前置摄像头" forState:UIControlStateNormal];
        [self startRecording:0];
    }
    

}
- (void)clickOpenFlash:(UIButton*)button{
    if ([button.titleLabel.text containsString:@"⚡︎"]) {
        [_MucaptureSession setFlashLigtMode:AVCaptureFlashModeOn];
        [_flashButton setTitle:@"⚡️" forState:UIControlStateNormal];
    }else if ([button.titleLabel.text containsString:@"⚡️"]){
        [_MucaptureSession setFlashLigtMode:AVCaptureFlashModeOff];
        [_flashButton setTitle:@"⚡︎" forState:UIControlStateNormal];
        
    }
}
- (void)clickChangeFocus:(UIButton*)button{
    if (_isBigScale == YES) {
        _zommFactor += 0.1;
        _MucaptureSession.zoomFactor = _zommFactor;
        [_MucaptureSession setFocus:_zommFactor];
        if (_zommFactor > 1.9) {
            _isBigScale = NO;
            [_focusButton setTitle:@"-" forState:UIControlStateNormal];
        }
    }else if (_isBigScale == NO){
        _zommFactor -= 0.1;
        [_MucaptureSession setFocus:_zommFactor];
        if (_zommFactor < 1.1) {
            _isBigScale = YES;
            [_focusButton setTitle:@"+" forState:UIControlStateNormal];
        }
    }
    NSLog(@"zoom factor:%f",_zommFactor);

}
#pragma mark--MUCaptureSessionDelegate
- (void)userRejectToAuthorization{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请在系统个人设置中设置照相权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
    
    
}
- (void)endRecodingPlayWithURL:(NSURL *)url{
    //[_MucaptureSession.captureSession stopRunning];
    if (url == nil) {
        return;
    }
    PostVideoViewController *poVC = [[PostVideoViewController alloc]init];
    poVC.url = url;
    [self.navigationController pushViewController:poVC animated:YES];
    

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark--回调函数
- (void)initVideoWriter{
   // CGSize size = CGSizeMake(480, 320);
//    
//    NSError *error = nil;
//    unlink([betaCompressionDict UTF8String]);
//    
//    //本地写入
//    _assetWriter = [[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:betaCompressionDict] fileType:AVFileTypeQuickTimeMovie error:&error];
//    NSParameterAssert(_assetWriter);
//    
//    //错误处理
//    if (error) {
//        NSLog(@"error = %@",[error localizedDescription]);
//    }else{
//    
//    
//    
//    
//    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
