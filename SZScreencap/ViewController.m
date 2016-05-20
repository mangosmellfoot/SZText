//
//  ViewController.m
//  SZScreencap
//
//  Created by MapABCios on 16/5/19.
//  Copyright © 2016年 MapABCios. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

static NSString * StartRecord = @"开始";
static NSString * StopRecord = @"停止";

#define APPWidth [UIScreen mainScreen].bounds.size.width
#define APPHeight [UIScreen mainScreen].bounds.size.height

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#define AnimationDurion (0.5)

@interface ViewController ()<RPPreviewViewControllerDelegate>

@property(weak,nonatomic) UIButton * btnStart;
@property(weak,nonatomic) UIButton * btnStop;
@property(weak,nonatomic) UIActivityIndicatorView * indicatorView;
@property(weak,nonatomic) UIView * viewTip;
@property(weak,nonatomic) UILabel * labelTip;
@property(weak,nonatomic) UILabel * labelTime;
@property(weak,nonatomic) UIProgressView * progress;
@property(nonatomic) NSTimer * timerProgress;

@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    BOOL isVersionOK = [self isSystemVersionOk];
    //检测系统等级
    if (!isVersionOK)
    {
        NSLog(@"Sorry!只支持IOS9.0以上系统使用！");
        return;
    }
    //检测调试环境
    if(SIMULATOR)
    {
        [self showWarningWithTitle:@"RePlay不支持模拟器" andMessage:@"请在真机上运行这个工程" andOKString:@"确定" andCancelString:@"取消" andOkAction:nil andAcncelAction:nil];
        return;
    }
    
    UILabel * labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(APPWidth * 0.5 - 50, 100, 100, 60)];
    labelTitle.font = [UIFont boldSystemFontOfSize:32];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelTitle];
    
    UIButton * buttonStart = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, APPWidth * 0.5 - 100, 75)];
    [buttonStart setTitle:StartRecord forState:UIControlStateNormal];
    buttonStart.titleLabel.font =  [UIFont systemFontOfSize:20];
    [self.view addSubview:buttonStart];
    self.btnStart = buttonStart;
    
    UIButton * buttonStop = [[UIButton alloc] initWithFrame:CGRectMake(APPWidth * 0.5 + 50, 200, APPWidth - 100, 75)];
    [buttonStop setTitle:StopRecord forState:UIControlStateNormal];
    buttonStop.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:buttonStop];
    self.btnStop = buttonStop;
    
    //loading指示
    UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView = indicatorView;
    UIView * view= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = 8.f;
    view.center = CGPointMake(APPWidth * 0.5, 300);
    indicatorView.center = CGPointMake(30, view.frame.size.height * 0.5);
    [view addSubview:indicatorView];
    UILabel * labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
    labelTip.font = [UIFont systemFontOfSize:20];
    labelTip.backgroundColor = [UIColor clearColor];
    labelTip.textColor = [UIColor blackColor];
    labelTip.layer.cornerRadius = 4.f;
    labelTip.textAlignment = NSTextAlignmentCenter;
    [view addSubview:labelTip];
    self.labelTip = labelTip;
    self.viewTip = view;
    
    //显示时间
    UILabel * labelTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    labelTime.font = [UIFont systemFontOfSize:20];
    labelTime.backgroundColor = [UIColor redColor];
    labelTime.textColor = [UIColor blackColor];
    labelTime.layer.cornerRadius = 4.f;
    labelTime.textAlignment = NSTextAlignmentCenter;
    self.labelTime = labelTime;
    NSDateFormatter * dateFormattre = [[NSDateFormatter alloc] init];
    [dateFormattre setDateFormat:@"HH:mm:ss"];
    NSString * strDate = [dateFormattre stringFromDate:[NSDate date]];
    labelTime.text = strDate;
    labelTime.center = CGPointMake(APPWidth * 0.5, APPHeight * 0.5 + 100);
    [self.view addSubview:labelTime];
    
    UIProgressView * progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, APPWidth * 0.8, 10)];
    progress.center = CGPointMake(APPWidth/2, APPHeight/2 + 150);
    progress.progressViewStyle = UIProgressViewStyleDefault;
    progress.progress = 0.0;
    [self.view addSubview:progress];
    self.progress = progress;
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateTimer) userInfo:nil repeats:NO];
    
    
    
}

#pragma mark - function

- (BOOL)isSystemVersionOk
{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 0.9)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)showWarningWithTitle:(NSString *)title andMessage:(NSString *)message andOKString:(NSString *)strOK andCancelString:(NSString *)strCancel andOkAction:(void(^)(UIAlertAction * action))actionOK andAcncelAction:(void(^)(UIAlertAction * action))actionCancel
{
    UIAlertAction * actionAltOK = [UIAlertAction actionWithTitle:strOK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(actionOK)
        {
            actionOK(action);
        }
    }];
    UIAlertAction * actionAltCancel = [UIAlertAction actionWithTitle:strCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(actionCancel)
        {
            actionCancel(action);
        }
    }];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:actionAltOK];
    [alertController addAction:actionAltCancel];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)hideTip
{
    self.viewTip.hidden = YES;
    [self.indicatorView stopAnimating];
}


















@end
