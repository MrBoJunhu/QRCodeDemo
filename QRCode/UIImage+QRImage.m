//
//  UIImage+QRImage.m
//  QRCode
//
//  Created by BillBo on 2017/9/21.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "UIImage+QRImage.h"

@implementation UIImage (QRImage)

+(UIImage *)imageOfQRFromURL:(NSString *)url codeSize:(CGFloat)codeSize {
    
    if (!url ||[url isKindOfClass:[NSNull class]]) {
        
        return nil;
        
    }else{
        
        codeSize = [self validateCodeSize:codeSize];
        
        CIImage *originImage = [self createQRFromURL:url];
        
        //
//        UIImage *image = [UIImage imageWithCIImage:originImage];
        //对二维码图片做清晰化处理
        UIImage *image = [UIImage excludeFuzzyImageFromCIImage:originImage size:codeSize];
      
        return image;
        
    }
    
}
+(CGFloat)validateCodeSize:(CGFloat)codeSize{
    
    codeSize = MAX(160, codeSize);
    
    codeSize = MIN(CGRectGetWidth([UIScreen mainScreen].bounds) - 80, codeSize);
    
    return  codeSize;
}

/*! 利用系统滤镜生成二维码图*/
+(CIImage *)createQRFromURL:(NSString *)url {
    
    NSData *stringData = [url dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

/*! 对图像进行清晰化处理*/
+(UIImage *)excludeFuzzyImageFromCIImage:(CIImage *)image size:(CGFloat)size{
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    //创建灰度色调空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    CGColorSpaceRelease(colorSpace);

    return [UIImage imageWithCGImage: scaledImage];

}
#pragma mark - 自定义二维码样色样式

+(UIImage *)imageOfQRFromURL:(NSString *)url codesize:(CGFloat)codesize red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue {
    
    UIImage *progressImage = [UIImage imageOfQRFromURL:url codeSize:codesize];
        
    UIImage *effectiveImage = [self imageFillBlackColorAndTransparent:progressImage red:red green:green blue:blue];
        
    return effectiveImage;
}

/*! 对生成二维码图像进行颜色填充*/

+ (UIImage *)imageFillBlackColorAndTransparent: (UIImage *)image red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue {
  
    const int imageWidth = image.size.width;
    
    const int imageHeihgt = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeihgt);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeihgt, 8, bytesPerRow, colorSpace, kCGImageByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, (CGRect){(CGPointZero),(image.size)}, image.CGImage);
    
    //遍历像素
    int pixeINumber = imageHeihgt * imageWidth;
    
    [self fillWhiteToTransparentOnPixel:rgbImageBuf pixelNum:pixeINumber red:red green:green blue:blue];
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeihgt, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextRelease(context);
    
    return resultImage;
}


/*! 遍历所有像素点进行颜色替换*/
+ (void)fillWhiteToTransparentOnPixel: (uint32_t *)rgbImageBuf pixelNum: (int)pixelNum red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue{
    
    uint32_t * pCurPtr = rgbImageBuf;
   
    for (int i = 0 ; i < pixelNum; i++,pCurPtr++) {
        if ((*pCurPtr & 0xffffff00) < 0xd0d000) {
            
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            //将白色变成透明色
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }

}



#pragma mark - 在二维码中间位置插入图片
+(UIImage *)imageOfQRFromURL:(NSString *)url codeSize:(CGFloat)codeSize insertImage:(UIImage *)inserImage radius:(CGFloat)radius red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue{
    
    UIImage *effectiveImage = [UIImage imageOfQRFromURL:url codesize:codeSize red:red green:green blue:blue];
    
    return [self imageInsertedImage:effectiveImage insertImage:inserImage radius:5];
}

/*! 在二维码原图中心位置插入圆角图像*/

+ (UIImage *)imageInsertedImage: (UIImage *)originImage insertImage: (UIImage *)insertImage radius: (CGFloat)radius {
    
    if (!insertImage) { return originImage; }
    
    insertImage = [UIImage imageOfRoundRectWithImage: insertImage size: insertImage.size radius: radius];
    
    UIImage * whiteBG = [UIImage imageNamed: @"whiteBG"];
    
    whiteBG = [UIImage imageOfRoundRectWithImage: whiteBG size: whiteBG.size radius: radius];
    
    //白色边缘宽度
    
    const CGFloat whiteSize = 2.f;
    
    CGSize brinkSize = CGSizeMake(originImage.size.width / 4, originImage.size.height / 4);
    
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
    
    CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
    
    CGFloat imageX = brinkX + whiteSize;
    
    CGFloat imageY = brinkY + whiteSize;
    
    UIGraphicsBeginImageContext(originImage.size);
    
    [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
    
    [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
    
    [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
    
}

+ (UIImage *)imageOfRoundRectWithImage: (UIImage *)image size: (CGSize)size radius: (CGFloat)radius {
    
    if (!image) { return nil; }
    
    const CGFloat width = size.width;
    
    const CGFloat height = size.height;
    
    radius = MAX(5.f, radius);
    
    radius = MIN(10.f, radius);
    
    UIImage * img = image;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //绘制圆角
    
    CGContextBeginPath(context);
    
    addRoundRectToPath(context, rect, radius, img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    
    img = [UIImage imageWithCGImage: imageMasked];
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    CGImageRelease(imageMasked);
    
    return img;
    
}

#pragma mark - private
/**
 *  给上下文添加圆角蒙版
 */
void addRoundRectToPath(CGContextRef context, CGRect rect, float radius, CGImageRef image) {
    float width, height;
    if (radius == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    width = CGRectGetWidth(rect);
    height = CGRectGetHeight(rect);
    
    //裁剪路径
    CGContextMoveToPoint(context, width, height / 2);
    CGContextAddArcToPoint(context, width, height, width / 2, height, radius);
    CGContextAddArcToPoint(context, 0, height, 0, height / 2, radius);
    CGContextAddArcToPoint(context, 0, 0, width / 2, 0, radius);
    CGContextAddArcToPoint(context, width, 0, width, height / 2, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRestoreGState(context);
}

void ProviderReleaseData(void * info, const void * data, size_t size) {
    
    free((void *)data);
    
}
@end
