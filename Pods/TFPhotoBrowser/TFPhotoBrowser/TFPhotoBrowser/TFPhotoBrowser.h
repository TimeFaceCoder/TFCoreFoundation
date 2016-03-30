//
//  TFPhotoBrowser.h
//  TFPhotoBrowser
//
//  Created by Melvin on 8/28/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFPhotoProtocol.h"
#import "TFPhoto.h"

// Delgate
@protocol TFPhotoBrowserDelegate;

@class TFPhotoBrowser;
@class TFPhotoCaptionView;

@protocol TFPhotoBrowserDelegate <NSObject>
@optional
- (NSUInteger)numberOfPhotosInPhotoBrowser:(TFPhotoBrowser *)photoBrowser;
- (id <TFPhoto>)photoBrowser:(TFPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
- (id <TFPhoto>)photoBrowser:(TFPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (TFPhotoCaptionView *)photoBrowser:(TFPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(TFPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(TFPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index section:(NSInteger)section;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index section:(NSInteger)section selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(TFPhotoBrowser *)photoBrowser;
- (UIView *)photoBrowser:(TFPhotoBrowser *)photoBrowser toolBarViewForPhotoAtIndex:(NSUInteger)index;
- (NSDictionary*)photoBrowserSelecteNum;
//tag
- (NSMutableArray *)photoBrowser:(TFPhotoBrowser *)photoBrowser tagInfosAtIndex:(NSUInteger)index;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser updateTagInfo:(NSDictionary *)info index:(NSUInteger)index;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser infos:(NSMutableArray *)infos;
- (void)updatePhotoInfos:(NSMutableArray *)array photoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser didSelectTagAtIndex:(NSInteger)index tagId:(NSString*)tagId;
@end


@interface TFPhotoBrowser : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) id<TFPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;

@property (nonatomic ,strong) NSIndexPath* indexPath;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;
@property (nonatomic, strong) UIView *customToolBarView;

//Animation
@property (nonatomic, weak) UIImage *scaleImage;
@property (nonatomic) BOOL usePopAnimation;
@property (nonatomic) float animationDuration;

//tag
@property (nonatomic, strong  ) NSMutableArray *tagInfos;
@property (nonatomic, strong  ) NSDictionary   *expandData;


// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <TFPhotoBrowserDelegate>)delegate;


- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view;
- (id)initWithDelegate:(id <TFPhotoBrowserDelegate>)delegate animatedFromView:(UIView*)view;

/**
 *  配置当前page tag view
 *
 *  @param index
 */
- (void)configurePageTag:(NSUInteger)index;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end

