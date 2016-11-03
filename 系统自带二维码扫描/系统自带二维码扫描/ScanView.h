//
//  ScanView.h
//  系统自带二维码扫描
//
//  Created by 周少文 on 15/9/3.
//  Copyright (c) 2015年 ZheJiangWangHang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanView : UIView

@property (nonatomic,strong) UIButton *flashBtn;
@property (nonatomic,strong) UIButton *selectImageBtn;
@property (nonatomic,strong) CALayer *scanLine;
@end
