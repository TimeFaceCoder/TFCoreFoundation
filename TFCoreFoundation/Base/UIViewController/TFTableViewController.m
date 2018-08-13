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
    self.batchShouldLoadInFirstPage = YES;
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
    
    if (!self.listType) {
        NSAssert(!self.listType, @"not set the value of list type.");
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

#pragma mark - public methods.
- (void)startLoadData {
    // 显示state view
    [self tf_showStateView:kTFViewStateLoading];
    [self.dataSource startLoadingWithParams:self.requestParams];
}

- (void)reloadDataSourceWith:(NSInteger)listType params:(NSDictionary *)params {
    _requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
    _dataSource = nil;
    //重新加载数据
    [self startLoadData];
}

- (void)setupListTypeUrlRelation {
    
}

#pragma mark - lazy load.

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
        _tableView.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
        if (self.tableViewStyle==UITableViewStylePlain) {
            _tableView.tableFooterView = [[UIView alloc] init];
        }
        _tableView.estimatedRowHeight = 44.0;
        _tableView.frame = self.view.bounds;
    }
    return _tableView;
}

- (ASTableNode *)tableNode {
    if (!_tableNode) {
        _tableNode = [[ASTableNode alloc] initWithStyle:self.tableViewStyle];
        _tableNode.frame = self.view.bounds;
        _tableNode.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
        if (self.tableViewStyle==UITableViewStylePlain) {
            _tableNode.view.tableFooterView = [[UIView alloc] init];
        }
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
                _dataSource.batchRequestArr = self.batchRequestArr;
                _dataSource.batchShouldLoadInFirstPage = self.batchShouldLoadInFirstPage;
            }
                break;
            case TFTableViewTypeASTableNode: {
                _dataSource = [[dataSourceClass alloc] initWithTableNode:self.tableNode listType:self.listType params:self.requestParams delegate:self];
                _dataSource.batchRequestArr = self.batchRequestArr;
                _dataSource.batchShouldLoadInFirstPage = self.batchShouldLoadInFirstPage;
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

#pragma mark - TFEmptyDataSetDataSource and Delegate.

- (void)emptyDataSet:(UIView *)view didTapButton:(UIButton *)button {
    [self startLoadData];
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
