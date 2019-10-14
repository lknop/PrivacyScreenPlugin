/**
 * PrivacyScreenPlugin.m
 * Created by Tommy-Carlos Williams on 18/07/2014
 * Copyright (c) 2014 Tommy-Carlos Williams. All rights reserved.
 * MIT Licensed
 */
#import "PrivacyScreenPlugin.h"

static UIImageView *imageView;

@implementation PrivacyScreenPlugin

- (void)pluginInitialize
{
//   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
//                                                name:UIApplicationDidBecomeActiveNotification object:nil];

//   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:)
//                                                name:UIApplicationWillResignActiveNotification object:nil];
}

- (void) hidePrivacyScreen:(CDVInvokedUrlCommand*)command
{
  if (imageView != NULL) {
    [imageView removeFromSuperview];
  }
}

- (void) showPrivacyScreen:(CDVInvokedUrlCommand*)command
{
  CDVViewController *vc = (CDVViewController*)self.viewController;
  
  NSString *imgName = [self getImageName:(id<CDVScreenOrientationDelegate>)vc device:[self getCurrentDevice]];
  UIImage *splash = [UIImage imageNamed:imgName];
  if (splash != NULL) {
    imageView = [[UIImageView alloc]initWithFrame:[self.viewController.view bounds]];
    [imageView setImage:splash];
    
    #ifdef __CORDOVA_4_0_0
        [[UIApplication sharedApplication].keyWindow addSubview:imageView];
    #else
        [self.viewController.view addSubview:imageView];
    #endif
  }
}

// Code below borrowed from the CDV splashscreen plugin @ https://github.com/apache/cordova-plugin-splashscreen
// Made some adjustments though, becuase landscape splashscreens are not available for iphone < 6 plus
- (CDV_iOSDevice) getCurrentDevice
{
  CDV_iOSDevice device;
  
  UIScreen* mainScreen = [UIScreen mainScreen];
  CGFloat mainScreenHeight = mainScreen.bounds.size.height;
  CGFloat mainScreenWidth = mainScreen.bounds.size.width;
  
  int limit = MAX(mainScreenHeight,mainScreenWidth);
  
  device.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
  device.iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
  device.retina = ([mainScreen scale] == 2.0);
  device.iPhone4 = (device.iPhone && limit == 480.0);
  device.iPhone5 = (device.iPhone && limit == 568.0);
  // note these below is not a true device detect, for example if you are on an
  // iPhone 6/6+ but the app is scaled it will prob set iPhone5 as true, but
  // this is appropriate for detecting the runtime screen environment
  device.iPhone6 = (device.iPhone && limit == 667.0);
  device.iPhone6Plus = (device.iPhone && limit == 736.0);
  device.iPhoneX = (device.iPhone && (limit == 812.0 || limit == 896.0));
  
  return device;
}

- (NSString*)getImageName:(id<CDVScreenOrientationDelegate>)orientationDelegate device:(CDV_iOSDevice)device
{
    
    NSString* imageName;
    
    NSString* privacyImageNameKey = @"privacyimagename";
    NSString* prefImageName = [self.commandDelegate.settings objectForKey:[privacyImageNameKey lowercaseString]];
    imageName = prefImageName ? prefImageName : @"Default";
    //Override Launch images?
    NSString* privacyOverrideLaunchImage = @"privacyoverridelaunchimage";
    if([self.commandDelegate.settings objectForKey:[privacyOverrideLaunchImage lowercaseString]] && [[self.commandDelegate.settings objectForKey:[privacyOverrideLaunchImage lowercaseString]] isEqualToString:@"true"])
    {
        
    }
    else
    {
        // Use UILaunchImageFile if specified in plist.  Otherwise, use Default.
        imageName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UILaunchImageFile"];
        imageName = [imageName stringByDeletingPathExtension];
    }
    
    NSUInteger supportedOrientations = [orientationDelegate supportedInterfaceOrientations];
    
    // Checks to see if the developer has locked the orientation to use only one of Portrait or Landscape
    BOOL supportsLandscape = (supportedOrientations & UIInterfaceOrientationMaskLandscape);
    BOOL supportsPortrait = (supportedOrientations & UIInterfaceOrientationMaskPortrait || supportedOrientations & UIInterfaceOrientationMaskPortraitUpsideDown);
    // this means there are no mixed orientations in there
    BOOL isOrientationLocked = !(supportsPortrait && supportsLandscape);
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    // Add Asset Catalog specific prefixes
    if ([imageName isEqualToString:@"LaunchImage"])
    {
        if(device.iPhone4 || device.iPhone5 || device.iPad) {
            imageName = [imageName stringByAppendingString:@"-700"];
        } else if(device.iPhone6) {
            imageName = [imageName stringByAppendingString:@"-800"];
        } else if(device.iPhone6Plus || device.iPhoneX) {
            if(device.iPhone6Plus) {
                imageName = [imageName stringByAppendingString:@"-800"];
            } else {
                imageName = [imageName stringByAppendingString:@"-1100"];
            }
            if (deviceOrientation == UIDeviceOrientationPortrait || deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                imageName = [imageName stringByAppendingString:@"-Portrait"];
            }
        }
    }
    
    BOOL isLandscape = supportsLandscape &&
    (deviceOrientation == UIDeviceOrientationLandscapeLeft || deviceOrientation == UIDeviceOrientationLandscapeRight);
    
    if (device.iPhone4) { // does not support landscape
        imageName = isLandscape ? nil : [imageName stringByAppendingString:@"-480h"];
    } else if (device.iPhone5) { // does not support landscape
        imageName = isLandscape ? nil : [imageName stringByAppendingString:@"-568h"];
    } else if (device.iPhone6) { // does not support landscape
        imageName = isLandscape ? nil : [imageName stringByAppendingString:@"-667h"];
    } else if (device.iPhone6Plus || device.iPhoneX)
    { // supports landscape
        if (isOrientationLocked) {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"")];
        } else {
            switch (deviceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;
                default:
                    break;
            }
        }
        if (device.iPhoneX) {
            imageName = [imageName stringByAppendingString:@"-2436h"];
        } else {
            imageName = [imageName stringByAppendingString:@"-736h"];
        }
        
    } else if (device.iPad) { // supports landscape
        if (isOrientationLocked) {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"-Portrait")];
        } else {
            switch (deviceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;
                    
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown:
                default:
                    imageName = [imageName stringByAppendingString:@"-Portrait"];
                    break;
            }
        }
    }

    return imageName;
}

@end
