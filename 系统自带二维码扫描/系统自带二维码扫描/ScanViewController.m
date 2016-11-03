//
//  ScanViewController.m
//  系统自带二维码扫描
//
//  Created by 周少文 on 15/9/3.
//  Copyright (c) 2015年 ZheJiangWangHang. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>



#import "ScanView.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ScanViewController


- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    //初始化设备(摄像头)
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    //创建输出流
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //设置输出的代理,在主线程里刷新
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //用串行队列新线程结果在UI上显示较慢
    
    //实例化捕捉会话并添加输入,输出流
    _session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if([_session canAddInput:_deviceInput])
    {
        [_session addInput:_deviceInput];
    }
    
    if([_session canAddOutput:_metadataOutput])
    {
        [_session addOutput:_metadataOutput];
    }
    
    _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,         //二维码
                                            AVMetadataObjectTypeCode39Code,     //条形码   韵达和申通
                                            AVMetadataObjectTypeCode128Code,    //CODE128条码  顺丰用的
                                            AVMetadataObjectTypeCode39Mod43Code,
                                            AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeEAN8Code,
                                            AVMetadataObjectTypeCode93Code,    //条形码,星号来表示起始符及终止符,如邮政EMS单上的条码
                                            AVMetadataObjectTypeUPCECode];
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResize;
    _previewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer addSublayer:_previewLayer];
    
    //初始化scanView的时候需要给他一个frame,否则初始化不了
    ScanView *scanView = [[ScanView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [scanView.flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [scanView.selectImageBtn addTarget:self action:@selector(selectImageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanView];
    [self createBackBtn];

    //如果不设置scanView的背景色为clearColor那么扫描界面会是一片黑色
    scanView.backgroundColor = [UIColor clearColor];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect clearRect = CGRectMake(screenWidth/2.0-100, screenHeight/2.0-100, 200, 200);
    //限制扫描的区别为透明矩形框
   _metadataOutput.rectOfInterest = CGRectMake(clearRect.origin.y/screenHeight, clearRect.origin.x/screenWidth, clearRect.size.height/screenHeight, clearRect.size.width/screenWidth);
     //_metadataOutput.rectOfInterest = CGRectMake(0.0,0.0, 1.0, 1.0);
    //开始扫描
    [_session startRunning];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"captureOutput");
    NSString *stringValue =nil;
    if(metadataObjects.count >0){
        //关闭扫描
        [_session stopRunning];
        _session = nil;
        [_previewLayer removeFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];
        stringValue = object.stringValue;
    }
    NSLog(@"%@",stringValue);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:stringValue delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)flashBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if(sender.selected)
    {
        //开启闪光灯
        if([self.device hasTorch] &&[self.device hasFlash])
        {
            if(self.device.torchMode ==AVCaptureTorchModeOff)
            {
                [self.session beginConfiguration];
                [self.device lockForConfiguration:nil];
                [self.device setTorchMode:AVCaptureTorchModeOn];
                [self.device setFlashMode:AVCaptureFlashModeOn];
                [self.device unlockForConfiguration];
                [self.session commitConfiguration];
            }
        }
    }else
    {
        //关闭闪光灯
        [self.session beginConfiguration];
        [self.device lockForConfiguration:nil];
        if(self.device.torchMode == AVCaptureTorchModeOn)
        {
            [self.device setTorchMode:
             AVCaptureTorchModeOff];
            [self.device setFlashMode:AVCaptureFlashModeOff];
        }
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];

    }

}

- (void)createBackBtn
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 20, 50, 50)
    ;
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
}

- (void)backBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


//- (void)selectImageBtnClick:(UIButton *)sender
//{
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//    {
//        //用UIImagePickerController打开系统相册默认是显示英文的.如果要显示中文需要点击蓝色的工程文件PROJECT > Info > Localizations添加简体中文
//        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//        imagePickerController.delegate = self;
//        [self presentViewController:imagePickerController animated:YES completion:nil];
//        
//    }
//}
//
//#pragma mark - UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    //不加下面的代码imagePickerController是无法dismiss的,除非你不重写这个代理方法
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


@end
