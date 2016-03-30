//
//  TFMediaViewController.m
//  TFCamera
//
//  Created by Melvin on 7/28/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFMediaViewController.h"
#import "TFCameraColor.h"
#import "TFTintedButton.h"
#import <Masonry/Masonry.h>
#import "UIButton+TFCameraButton.h"

const static CGFloat kToolBarHeight    = 50.0f;

const static CGFloat kBottomHeight     = 80.0f;

const static CGFloat kBottomButtonSize = 36.0f;

const static CGFloat kLeftPadding      = 20.0f;

@interface TFMediaViewController ()
/**
 *  顶部工具条
 */
@property (nonatomic ,strong) UIView           *topView;
/**
 *  底部工具条
 */
@property (nonatomic ,strong) UIView           *actionsView;
/**
 *  图片
 */
@property (nonatomic ,strong) UIImageView      *photoImageView;
/**
 *  底部工具条
 */
@property (nonatomic ,strong) UIView           *bottomView;
/**
 *  关闭按钮
 */
@property (nonatomic ,strong) UIButton         *closeButton;
/**
 *  下一步
 */
@property (nonatomic ,strong) UIButton         *nextButton;
/**
 *  图章按钮
 */
@property (nonatomic ,strong) UIButton         *stickerButton;
/**
 *  滤镜按钮
 */
@property (nonatomic ,strong) UIButton         *filterButton;
/**
 *  确认按钮
 */
@property (nonatomic ,strong) UIButton         *confirmButton;
/**
 *  资源文件
 */
@property (nonatomic ,strong) TFMediaFileModel *mediaFile;

@end

@implementation TFMediaViewController

+ (instancetype)newWithDelegate:(id<TFCameraDelegate>)delegate mediaFile:(TFMediaFileModel *)mediaFile {
    TFMediaViewController *viewController = [TFMediaViewController new];
    if (viewController) {
        viewController.mediaFile = mediaFile;
    }
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [TFCameraColor bottomBgColor];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.photoImageView];
    [self.view addSubview:self.bottomView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(kToolBarHeight);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(kBottomHeight);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.top.mas_equalTo(_topView.mas_bottom);
        make.bottom.mas_equalTo(_bottomView.mas_top);
    }];
    //Buttons
    [_topView addSubview:self.closeButton];
    [_topView addSubview:self.nextButton];
    [_bottomView addSubview:self.stickerButton];
    [_bottomView addSubview:self.filterButton];
    [_bottomView addSubview:self.confirmButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView.mas_centerY);
        make.leading.mas_equalTo(kLeftPadding);
    }];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView.mas_centerY);
        make.right.equalTo(_topView.mas_right).offset(- kLeftPadding);
    }];
    [_stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
        make.right.equalTo(_bottomView.mas_right).offset(- kLeftPadding);
        make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
    }];
    [_filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kLeftPadding);
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
    }];
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_bottomView.mas_centerX);
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    _topView        = nil;
    _photoImageView = nil;
    _bottomView     = nil;
    _mediaFile      = nil;
}

#pragma mark -

#pragma mark - Views

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [TFCameraColor topBgColor];
    }
    return _topView;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _photoImageView.backgroundColor = [UIColor clearColor];
        _photoImageView.image = _mediaFile.image;
        _photoImageView.layer.borderWidth = 1;
        _photoImageView.layer.borderColor = [[UIColor blueColor] CGColor];
    }
    return _photoImageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [TFCameraColor bottomBgColor];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

#pragma mark - 
#pragma mark Buttons
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton tfcCreateButtonWithImage:@"CameraBack.png"
                                             imagePressed:@"CameraBack.png"
                                                   target:self
                                                 selector:@selector(closeTapped)];
        _closeButton.showsTouchWhenHighlighted = YES;
    }
    return _closeButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton tfcCreateButtonWithTitle:@"下一步"
                                                  target:self
                                                selector:@selector(nextTapped)];
        _nextButton.tintColor = [TFCameraColor tintColor];
    }
    return _nextButton;
}

- (UIButton *)stickerButton {
    if (!_stickerButton) {
        _stickerButton = [UIButton tfcCreateButtonWithImage:@"CameraSticker.png"
                                               imagePressed:@"CameraSticker.png"
                                                     target:self
                                                   selector:@selector(stickerTapped)];
        _stickerButton.showsTouchWhenHighlighted = YES;
    }
    return _stickerButton;
}

- (UIButton *)filterButton {
    if (!_filterButton) {
        _filterButton = [UIButton tfcCreateButtonWithImage:@"CameraFilter.png"
                                              imagePressed:@"CameraFilter.png"
                                                    target:self
                                                  selector:@selector(filterTapped)];
        _filterButton.showsTouchWhenHighlighted = YES;
    }
    return _filterButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton tfcCreateButtonWithImage:@"CameraShot.png"
                                               imagePressed:@"CameraShot.png"
                                                     target:self
                                                   selector:@selector(confirmTapped)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CameraCheckMark.png"]];
        [_confirmButton addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_confirmButton.mas_centerX);
            make.centerY.mas_equalTo(_confirmButton.mas_centerY);
        }];
    }
    return _confirmButton;
}

#pragma mark - 
#pragma mark Actions

- (void)closeTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextTapped {
    
}

- (void)stickerTapped {
    
}

- (void)filterTapped {
    
}

- (void)confirmTapped {
    
}

@end
