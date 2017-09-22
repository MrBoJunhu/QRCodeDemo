//
//  ScanViewController.m
//  QRCode
//
//  Created by BillBo on 2017/9/22.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "ScanViewController.h"

#import "ZHScanView.h"

@interface ScanViewController (){
    ZHScanView *scanView;
}

@property (strong, nonatomic) IBOutlet UIView *scanV;

@end

@implementation ScanViewController

- (void)viewDidLoad {
  
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.title = @"扫一扫";
    
    scanView = [[ZHScanView alloc] initWithFrame:CGRectMake(0, 0, self.scanV.frame.size.width , self.scanV.frame.size.height)];
    
    scanView.backgroundColor = [UIColor lightGrayColor];
    
    scanView.promptMessage = @"请扫描二维码";
    
    [scanView startScaning];
    
    [scanView outPutResult:^(NSString *result) {
        
        NSLog(@"扫描结果 %@", result);
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"扫描结果" message:result preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
            
        }];
        
        [alertC addAction:ok];
        
        [self presentViewController:alertC animated:YES completion:^{
            
        }];
        
    }];
    
    [self.scanV addSubview:scanView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [scanView scanAgain];
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

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
