//
//  ViewController.m
//  QRCode
//
//  Created by BillBo on 2017/9/21.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+QRImage.h"
@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *QRImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIImage *image = [UIImage imageOfQRFromURL:@"http://www.jianshu.com/p/d90cd2cb41d7" codeSize:100];;

//    UIImage *image = [UIImage imageOfQRFromURL:@"http://www.jianshu.com/p/d90cd2cb41d7" codesize:100 red:217 green:67 blue:72];
    
    UIImage *image = [UIImage imageOfQRFromURL:@"http://www.jianshu.com/p/d90cd2cb41d7" codeSize:100 insertImage:[UIImage imageNamed:@"qq"] radius:5 red:217 green:67 blue:72];
    
    self.QRImageView.image = image;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
