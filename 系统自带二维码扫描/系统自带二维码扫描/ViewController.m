//
//  ViewController.m
//  系统自带二维码扫描
//
//  Created by 周少文 on 15/9/3.
//  Copyright (c) 2015年 ZheJiangWangHang. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *_tableView;
}

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"主界面";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick)];
    self.navigationItem.leftBarButtonItem = item;

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)itemClick
{
    if(![self isCameraAvailable])
        return;
    self.navigationController.navigationBarHidden = YES;
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 判断摄像头是否可用
- (BOOL)isCameraAvailable
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]&&[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        return YES;
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有摄像头或者摄像头不可用" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}



@end
