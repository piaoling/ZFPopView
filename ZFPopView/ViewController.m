//
//  ViewController.m
//  ZFPopView
//
//  Created by zhaofeng on 14-3-9.
//  Copyright (c) 2014年 GInspire. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showTitlePopView:(id)sender
{
    [ZFPopView popWithTitle:@"ZF is naive and simple"];
}

- (IBAction)showTitleMessagePopView:(id)sender
{
    [ZFPopView popWithTitle:@"ZF is naive and simple" message:@"ZF's wife, however, is a beauty....."];
}

- (IBAction)showCustomViewPopView:(id)sender
{
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 180)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ExampleImage.png"]];
    imageView.frame = CGRectMake(0, 60, 60, 60);
    [tmpView addSubview:imageView];
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 150, 180)];
    tmpLabel.text = @"(****((JKHHIUHIUHGIUOGU*(&*(Y&*YUGUYFYR^YTYUGOUGOUY";
    tmpLabel.numberOfLines = 0;
    [tmpView addSubview:tmpLabel];
    
    [ZFPopView popWithcontentView:tmpView];
}

- (IBAction)showTitleMessageCustomViewPopView:(id)sender
{
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 180)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ExampleImage.png"]];
    imageView.frame = CGRectMake(0, 60, 60, 60);
    [tmpView addSubview:imageView];
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 150, 180)];
    tmpLabel.text = @"(****((JKHHIUHIUHGIUOGU*(&*(Y&*YUGUYFYR^YTYUGOUGOUY";
    tmpLabel.numberOfLines = 0;
    [tmpView addSubview:tmpLabel];
    
    [ZFPopView popWithTitle:@"ZF is naive and simple"
                    message:@"ZF's wife, however, is a beauty....."
                contentView:tmpView];
}

@end
