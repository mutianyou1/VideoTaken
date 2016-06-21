//
//  PostVideoViewController.m
//  视频通话
//
//  Created by mutianyou1 on 16/4/19.
//  Copyright © 2016年 mutianyou1. All rights reserved.
//commit xcode

#import "PostVideoViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface PostVideoViewController (){
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    AVPlayerLayer *_fullLayer;
    BOOL _isPlaying;
    UIButton *_saveButton;

}

@end

@implementation PostVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpSaveButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self creatPlayer];
}
- (void)viewWillDisappear:(BOOL)animated{
    [_player pause];
    _player = nil;
    [super viewWillDisappear:animated];

}
- (void)setUpSaveButton{
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_saveButton setTitle:@"保存相册并压缩" forState:UIControlStateNormal];
    _saveButton.frame = CGRectMake(10, HEIGTH - 30, WIDTH - 20, 30);
    [_saveButton addTarget:self action:@selector(clickSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];


}
- (void)creatPlayer{
    _playerItem = [AVPlayerItem playerItemWithURL:_url];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 20, WIDTH, 300);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    [self.view.layer addSublayer:_playerLayer];
    [_player play];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_isPlaying) {
        _playerLayer.frame = [UIScreen mainScreen].bounds;
    }else{
        _playerLayer.frame = CGRectMake(0, 20, WIDTH, 300);
    }
    _isPlaying = !_isPlaying;

}
- (void)clickSave{
    _saveButton.enabled = YES;
    NSLog(@"开始压缩大小为：%fMB",[self fileSize:_url]);
    AVURLAsset *avAsset = [[AVURLAsset alloc]initWithURL:_url options:nil];
    NSArray *compatiablePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
   
    if ([compatiablePresets containsObject:AVAssetExportPresetLowQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [self outPutURL];
        //优化网络格式
        exportSession.shouldOptimizeForNetworkUse = YES;
        //转换后格式
        exportSession.outputFileType = AVFileTypeMPEG4;
        NSData *data = [NSData dataWithContentsOfURL:[self outPutURL]];
        if (data) {
            NSError *error = nil;
            NSString *path = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) firstObject] stringsByAppendingPaths:@[@"compressed.mp4"]] firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//            [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            //
//            } failureBlock:^(NSError *error) {
//                
//            }];
//            if (error) {
//                NSLog(@"删除压缩文件错误%@",error);
//            }
            
        }
        //异步倒出
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"完成后大小%fMB", [self fileSize:[self outPutURL]]);
                NSLog(@"保存文件名称%@",[self outPutURL]);
                [self saveVideo:[self outPutURL]];
            }else{
                NSLog(@"当前状态%ld",exportSession.status);
                NSLog(@"当前进度%f",exportSession.progress);
            }
            _saveButton.enabled = YES;
        }];
        
    }
    
}

- (void)playBackFinished:(NSNotification*)notification{
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

- (void)saveVideo:(NSURL*)url{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"压缩保存相册失败");
        }else {
            NSLog(@"压缩保存相册成功");
        }
    }];
}
- (CGFloat)fileSize:(NSURL*)url{
    return [[NSData dataWithContentsOfURL:url] length] / 1024 /1024;
}
- (NSURL*)outPutURL{
    return [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"compressed.mp4"]]];
    

}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
