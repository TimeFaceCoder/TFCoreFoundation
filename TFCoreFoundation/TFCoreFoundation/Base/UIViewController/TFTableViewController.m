//
//  TFTableViewController.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewController.h"
#import "UIViewController+TFCore.h"
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "TFDefaultStyle.h"
#import <TFTableViewDataSourceConfig.h>
#import "UIViewController+EmptyState.h"

NSString * const kTFTableViewTypeKey = @"TableViewTypeKey";
NSString * const kTFTableViewStyleKey = @"TableViewStyleKey";
NSString * const kTFTableViewListTypeKey = @"TableViewListType";
NSString * const kTFTableViewUsePullReloadKey = @"TableViewUsePullReloadKey";

@interface TFTableViewController() {
    CGFloat _lastPosition;
    BOOL _loaded;
    BOOL _isAnimating;
}

@property (nonatomic ,strong ,readwrite) ASTableNode *tableNode;
@property (nonatomic ,strong ,readwrite) UITableView *tableView;
@property (nonatomic ,strong ,readwrite) TFTableViewDataSource *dataSource;

@end

@implementation TFTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        //设置属性默认值
        [self _setDefaultPropertyValues];
    }
    return self;
}

- (void)_setDefaultPropertyValues {
    self.tableViewType = TFTableViewTypeASTableNode;
    self.tableViewStyle = UITableViewStylePlain;
    self.usePullReload = YES;
    _requestParams = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _loadDefaultPropertyValuesFromParams];
    //添加默认tableview
    if (self.tableViewType==TFTableViewTypeASTableNode) {
        [self.view addSubnode:self.tableNode];
    }
    else {
        [self.view addSubview:self.tableView];
    }
    //设置状态栏样式
    [JDStatusBarNotification addStyleNamed:@"scrollNotice"
                                   prepare:^JDStatusBarStyle*(JDStatusBarStyle *style)
     {
         style.barColor = [UIColor darkTextColor];
         style.textColor = [UIColor whiteColor];
         style.animationType = JDStatusBarAnimationTypeMove;
         return style;
     }];
    //设置滚动是否隐藏
    _hiddenTabBarWhenScrolling = YES;
    if (self.tabBarController.tabBar.hidden==YES | self.hidesBottomBarWhenPushed == YES) {
        self.hiddenTabBarWhenScrolling = NO;
    }
    
    // 显示state view
    [self tf_showStateView:kTFViewStateLoading];
    
    if (!self.listType) {
        NSAssert(self.listType, @"not set the value of list type.");
    }
    else {
        //开始第一次加载数据
        [self startLoadData];
    }
}

- (void)_loadDefaultPropertyValuesFromParams {
    // Custom initialization
    if ([self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewTypeKey]) {
        self.tableViewType = [[self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewTypeKey]integerValue];
    }
    
    if ([self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewStyleKey]) {
        self.tableViewStyle =  [[self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewStyleKey]integerValue];
    }
    
    if ([self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewUsePullReloadKey]) {
        self.usePullReload = [[self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewUsePullReloadKey] boolValue];
    }
    
    if ([self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewListTypeKey]) {
        self.listType = [[self.params[kTFNavigatorParameterUserInfo] objectForKey:kTFTableViewListTypeKey]integerValue];
    }

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_tableNode) {
        _tableNode.frame = self.view.bounds;
    }
    else {
        _tableView.frame = self.view.bounds;
    }
}

#pragma mark - public methods.
- (void)startLoadData {
    [self.dataSource startLoadingWithParams:self.requestParams];
}

#pragma mark - lazy load.

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
        _tableView.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 44.0f;
        _tableView.frame = self.view.bounds;
    }
    return _tableView;
}

- (ASTableNode *)tableNode {
    if (!_tableNode) {
        _tableNode = [[ASTableNode alloc] initWithStyle:self.tableViewStyle];
        _tableNode.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
        _tableNode.view.tableFooterView = [[UIView alloc] init];
    }
    return _tableNode;
}

- (TFTableViewDataSource *)dataSource {
    if (!_dataSource) {
        Class dataSourceClass = [[TFTableViewDataSourceConfig sharedInstance] dataSourceByListType:self.listType];
        switch (_tableViewType) {
            case TFTableViewTypeUITableView:
            {
                _dataSource = [[dataSourceClass alloc] initWithTableView:self.tableView listType:self.listType params:self.requestParams delegate:self];
            }
                break;
            case TFTableViewTypeASTableNode: {
                _dataSource = [[dataSourceClass alloc] initWithTableNode:self.tableNode listType:self.listType params:self.requestParams delegate:self];
            }
                break;
            default:
                break;
        }
        
    }
    return _dataSource;
}


#pragma mark - TFTableViewDataSourceDelegate

- (void)actionOnView:(TFTableViewItem *)item actionType:(NSInteger)actionType {
    
}

- (void)didFinishLoad:(TFDataLoadPolicy)loadPolicy object:(id)object error:(NSError *)error {
    if (!error) {
        [self tf_removeStateView];
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    else {
        if ([error.domain isEqualToString:TF_APP_ERROR_DOMAIN]) {
            NSInteger state = kTFViewStateNone;
            if (error.code == kTFErrorCodeAPI ||
                error.code == kTFErrorCodeHTTP ||
                error.code == kTFErrorCodeUnknown) {
                state = kTFViewStateDataError;
            }
            if (error.code == kTFErrorCodeNetwork) {
                state = kTFViewStateNetError;
            }
            if (error.code == kTFErrorCodeEmpty) {
                state = kTFViewStateNoData;
            }
            if (error.code == kTFErrorCodeLocationError) {
                state = kTFViewStateLocationError;
            }
            if (error.code == kTFErrorCodePhotosError) {
                state = kTFViewStatePhotosError;
            }
            if (error.code == kTFErrorCodeMicrophoneError) {
                state = kTFViewStateMicrophoneError;
            }
            if (error.code == kTFErrorCodeCameraError) {
                state = kTFViewStateCameraError;
            }
            if (error.code == kTFErrorCodeContactsError) {
                state = kTFViewStateContactsError;
            }
            [self tf_showStateView:state];
        }
        else {
            [self tf_showStateView:kTFViewStateDataError];
        }
    }
}

- (BOOL)showPullRefresh {
    return self.usePullReload;
}

- (void)scrollViewDidScroll:(UITableView *)tableView {
    
    CGFloat currentPostion = tableView.contentOffset.y;
    if (currentPostion - _lastPosition > 30) {
        _lastPosition = currentPostion;
        //向上滚动
        if (currentPostion > 3000) {
            BOOL noticed = [[NSUserDefaults standardUserDefaults] boolForKey:@"STORE_KEY_SCROLLNOTICE"];
            if (!noticed) {
                [JDStatusBarNotification showWithStatus:@"点击这里返回顶部"
                                           dismissAfter:1.5
                                              styleName:@"scrollNotice"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"STORE_KEY_SCROLLNOTICE"];
            }
        }
    }
    else if (_lastPosition - currentPostion > 30) {
        _lastPosition = currentPostion;
    }
}
- (void)scrollViewDidScrollUp:(CGFloat)deltaY {
    [self setTabBarHidden:YES];
}

- (void)scrollViewDidScrollDown:(CGFloat)deltaY {
    [self setTabBarHidden:NO];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp {
    [self setTabBarHidden:YES];
    
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown {
    [self setTabBarHidden:NO];
}

- (void)setTabBarHidden:(BOOL)hidden {
    if (self.tabBarController.tabBar && _hiddenTabBarWhenScrolling==YES) {
        if (self.tabBarController.tabBar.hidden!=hidden && self.tableView.contentSize.height>=(CGRectGetHeight(self.view.frame) - (self.tableView.contentInset.top + self.tableView.frame.origin.y + self.tableView.contentInset.bottom))) {
            _isAnimating = YES;
            
            CGRect frame = self.view.frame;
            if (hidden) {
                frame.size.height += 49;
            }
            else {
                frame.size.height -= 49;
            }
            self.view.frame = frame;
            
            [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.tabBarController.tabBar setHidden:hidden];
            } completion:^(BOOL finished) {
                _isAnimating = NO;
            }];
        }
    }
}

- (void)dealloc {
    [self.dataSource stopLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
