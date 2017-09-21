//
//  UIImage+QRImage.h
//  QRCode
//
//  Created by BillBo on 2017/9/21.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRImage)

+(UIImage *)imageOfQRFromURL:(NSString *)url codeSize:(CGFloat)codeSize;


+(UIImage *)imageOfQRFromURL:(NSString *)url codesize:(CGFloat)codesize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;

+(UIImage *)imageOfQRFromURL:(NSString *)url codeSize:(CGFloat)codeSize insertImage:(UIImage *)inserImage radius:(CGFloat)radius red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue;

@end
