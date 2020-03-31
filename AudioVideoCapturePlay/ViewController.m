//
//  ViewController.m
//  AudioVideoCapturePlay
//
//  Created by lisa on 2019/6/26.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "ViewController.h"
@import AudioToolbox;
//@import AVFoundation.AVFAudio;

#define kOutputBus 0
#define kInputBus 1

@interface ViewController ()
@property (nonatomic, strong) UIButton * captureAudioButton;
@property (nonatomic) AudioComponentInstance ioAudioUnit;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.captureAudioButton];
    self.captureAudioButton.center = CGPointMake(CGRectGetMidX(self.view.frame),100);
    
    /**
     音频capture 使用 audiotoolbox 代码: component -> audiounit -> config -> callback ->
     unit 是由 component 包装得来的,代表一个元件的逻辑意义
     componenttype:
     audiounit:input/output/effects/generators/mixser
     codec:encoders,decoders
     */
    
    // 音频元件描述
    AudioComponentDescription componentDes = {0};
    componentDes.componentType = kAudioUnitType_Output;
    componentDes.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDes.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // 获得一个音频 component
    AudioComponent audioComponent = AudioComponentFindNext(NULL, &componentDes);
    
    // 获得一个音频 unit
    OSStatus status = noErr;
    status = AudioComponentInstanceNew(audioComponent, &_ioAudioUnit);
    checkStatus(status);
    
    // 为录制打开IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(self.ioAudioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    checkStatus(status);
    
    // 为播放打开 IO
    status = AudioUnitSetProperty(self.ioAudioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &flag, sizeof(flag));
    checkStatus(status);
    
    // config
    AudioStreamBasicDescription streamDes = {0};
    streamDes.mSampleRate = 44100;
    streamDes.mFormatID = kAudioFormatLinearPCM;
    streamDes.mBitsPerChannel = 16;
    streamDes.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    streamDes.mChannelsPerFrame = 1;
    streamDes.mFramesPerPacket = 1;
    streamDes.mBytesPerFrame = streamDes.mBitsPerChannel / 8 * streamDes.mChannelsPerFrame;
    streamDes.mBytesPerPacket = streamDes.mBytesPerFrame * streamDes.mFramesPerPacket;
    
    status = AudioUnitSetProperty(self.ioAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kOutputBus, &streamDes, sizeof(streamDes));
    checkStatus(status);
    
    // call back
    AURenderCallbackStruct callback;
    callback.inputProcRefCon = (__bridge void *)(self);
    callback.inputProc = handleInputBuffer;
    
    AudioUnitSetProperty(self.ioAudioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &callback, sizeof(callback));
    
    // 启动 session
    //    AVAudioSession * session = [AVAudioSession sharedInstance];
    //    [session setPreferredSampleRate:44100 error:nil];
    //    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
    ////    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    //    [session setActive:YES error:nil];
    
    // init
    status = AudioUnitInitialize(self.ioAudioUnit);
    checkStatus(status);
}
- (void)captureAudioClick:(UIButton *)button {
    OSStatus status = AudioOutputUnitStart(self.ioAudioUnit);
    checkStatus(status);
}

void checkStatus(OSStatus status) {
    if (status != noErr) {
        ;
    }
}

static OSStatus handleInputBuffer (void * inRefCon,
                    AudioUnitRenderActionFlags * ioActionFlags,
                    const AudioTimeStamp *            inTimeStamp,
                    UInt32                            inBusNumber,
                    UInt32                            inNumberFrames,
                    AudioBufferList * __nullable    ioData) {
    
    return noErr;
}

#pragma mark - getters & setters
- (UIButton *)captureAudioButton {
    if (_captureAudioButton == nil) {
        _captureAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureAudioButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_captureAudioButton setTitle:@"capture audio" forState:UIControlStateNormal];
        [_captureAudioButton addTarget:self action:@selector(captureAudioClick:) forControlEvents:UIControlEventTouchUpInside];
        [_captureAudioButton setFrame:CGRectMake(0, 100, 300, 40)];
        
    }
    return _captureAudioButton;
}


@end
