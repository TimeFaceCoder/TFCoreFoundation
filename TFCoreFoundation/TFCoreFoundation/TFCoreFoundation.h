//
//  TFCoreFoundation.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<TFCoreFoundation/TFCoreFoundation.h>)

#import <TFCoreFoundation/TFCoreFoundationMacro.h>

///--------------------------------
/// @name Foundation Category
///--------------------------------

#import <TFCoreFoundation/NSObject+TFCore.h>
#import <TFCoreFoundation/NSObject+TFCoreForKVO.h>
#import <TFCoreFoundation/NSString+TFCore.h>
#import <TFCoreFoundation/NSNumber+TFCore.h>
#import <TFCoreFoundation/NSData+TFCore.h>
#import <TFCoreFoundation/NSArray+TFCore.h>
#import <TFCoreFoundation/NSDictionary+TFCore.h>
#import <TFCoreFoundation/NSDate+TFCore.h>
#import <TFCoreFoundation/NSNotificationCenter+TFCore.h>
///--------------------------------
/// @name UIKit Category
///--------------------------------
#import <TFCoreFoundation/UIDevice+TFCore.h>
#import <TFCoreFoundation/UIAlertController+TFCore.h>
#import <TFCoreFoundation/UIApplication+TFCore.h>
#import <TFCoreFoundation/UIView+TFCore.h>
#import <TFCoreFoundation/UIBarButtonItem+TFCore.h>
#import <TFCoreFoundation/UIBezierPath+TFCore.h>
#import <TFCoreFoundation/UIColor+TFCore.h>
#import <TFCoreFoundation/UIControl+TFCore.h>
#import <TFCoreFoundation/UIFont+TFCore.h>
#import <TFCoreFoundation/UIGestureRecognizer+TFCore.h>
#import <TFCoreFoundation/UIImage+TFCore.h>
#import <TFCoreFoundation/YYImage+TFCore.h>
#import <TFCoreFoundation/UIScreen+TFCore.h>
#import <TFCoreFoundation/UIScrollView+TFCore.h>
#import <TFCoreFoundation/UITableView+TFCore.h>
#import <TFCoreFoundation/UITextField+TFCore.h>
#import <TFCoreFoundation/UIWebView+TFCore.h>
#import <TFCoreFoundation/UIViewController+TFCore.h>
#import <TFCoreFoundation/UINavigationController+TFCore.h>
#import <TFCoreFoundation/TFCGUtilities.h>

///--------------------------------
/// @name Style
///--------------------------------

#import <TFCoreFoundation/TFStyle.h>
#import <TFCoreFoundation/TFDefaultStyle.h>

///--------------------------------
/// @name Cache
///--------------------------------

#import <TFCoreFoundation/TFKVStorage.h>

///--------------------------------
/// @name UIView
///--------------------------------

#import <TFCoreFoundation/TFNavigationBar.h>
#import <TFCoreFoundation/TFAlertView.h>
#import <TFCoreFoundation/TFSplashView.h>
#import <TFCoreFoundation/TFStateView.h>

///--------------------------------
/// @name Utility
///--------------------------------


///--------------------------------
/// @name UIViewController
///--------------------------------

#import <TFCoreFoundation/TFViewController.h>
#import <TFCoreFoundation/TFTableViewController.h>
#import <TFCoreFoundation/TFNavigationController.h>
#import <TFCoreFoundation/TFWebViewController.h>


///--------------------------------
/// @name Model
///--------------------------------
#import <TFCoreFoundation/TFModel.h>

#else


#import "TFCoreFoundationMacro.h"

///--------------------------------
/// @name Foundation Category
///--------------------------------

#import "NSObject+TFCore.h"
#import "NSObject+TFCoreForKVO.h"
#import "NSString+TFCore.h"
#import "NSNumber+TFCore.h"
#import "NSData+TFCore.h"
#import "NSArray+TFCore.h"
#import "NSDictionary+TFCore.h"
#import "NSDate+TFCore.h"
#import "NSNotificationCenter+TFCore.h"
///--------------------------------
/// @name UIKit Category
///--------------------------------
#import "UIDevice+TFCore.h"
#import "UIAlertController+TFCore.h"
#import "UIApplication+TFCore.h"
#import "UIView+TFCore.h"
#import "UIBarButtonItem+TFCore.h"
#import "UIBezierPath+TFCore.h"
#import "UIColor+TFCore.h"
#import "UIControl+TFCore.h"
#import "UIFont+TFCore.h"
#import "UIGestureRecognizer+TFCore.h"
#import "UIImage+TFCore.h"
#import "YYImage+TFCore.h"
#import "UIScreen+TFCore.h"
#import "UIScrollView+TFCore.h"
#import "UITableView+TFCore.h"
#import "UITextField+TFCore.h"
#import "UIWebView+TFCore.h"
#import "UIViewController+TFCore.h"
#import "UINavigationController+TFCore.h"
#import "TFCGUtilities.h"

///--------------------------------
/// @name Style
///--------------------------------

#import "TFStyle.h"
#import "TFDefaultStyle.h"

///--------------------------------
/// @name Cache
///--------------------------------

#import "TFKVStorage.h"

///--------------------------------
/// @name UIView
///--------------------------------

#import "TFNavigationBar.h"
#import "TFAlertView.h"
#import "TFSplashView.h"
#import "TFStateView.h"

///--------------------------------
/// @name Utility
///--------------------------------


///--------------------------------
/// @name UIViewController
///--------------------------------

#import "TFViewController.h"
#import "TFTableViewController.h"
#import "TFNavigationController.h"
#import "TFWebViewController.h"

///--------------------------------
/// @name Model
///--------------------------------
#import "TFModel.h"


#endif

