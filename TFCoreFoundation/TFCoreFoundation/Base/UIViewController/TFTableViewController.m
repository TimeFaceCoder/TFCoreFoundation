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

@interface TFTableViewController() {
    CGFloat lastPosition;
    BOOL _loaded;
}

@property (nonatomic ,strong ,readwrite) ASTableView           *tableView;
@property (nonatomic ,strong ,readwrite) TFTableViewDataSource *dataSource;


@end

@implementation TFTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableViewStyle = UITableViewStylePlain;
        self.usePullReload = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _tableView = [[ASTableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle asyncDataFetching:YES];
    _tableView.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}
- (void)viewWillLayoutSubviews {
    _tableView.frame = self.view.bounds;
}
- (void)createDataSource {
    if (self.params && [self.params objectForKey:@"listType"]) {
        [self setListType:[[self.params objectForKey:@"listType"] intValue]];
    }
    self.dataSource = [[[[TFTableViewDataSourceConfig sharedInstance] dataSourceClass] alloc] initWithTableView:_tableView
                                                                                                       listType:self.listType
                                                                                                         params:self.requestParams
                                                                                                       delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self createDataSource];
    [JDStatusBarNotification addStyleNamed:@"scrollNotice"
                                   prepare:^JDStatusBarStyle*(JDStatusBarStyle *style)
     {
         style.barColor = [UIColor darkTextColor];
         style.textColor = [UIColor whiteColor];
         style.animationType = JDStatusBarAnimationTypeMove;
         return style;
     }];
}


- (void)dealloc {
    [self.dataSource stopLoading];
    if (self.tableView) {
        self.tableView.asyncDataSource = nil;
        self.tableView.asyncDelegate = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.listType) {
        if (!_loaded) {
            [self startLoadData];
            _loaded = YES;
        }
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)autoReload:(NSNotification *)notification {
    [self startLoadData];
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated {
    NSAssert(YES, @"This method should be handled by a subclass!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLoadData {
    [self.dataSource startLoadingWithParams:self.requestParams];
}


- (void)reloadData {
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self removeStateView];
    [self startLoadData];
}

- (void)reloadCell:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        NSInteger actionType = [[userInfo objectForKey:@"type"] integerValue];
        NSString *identifier = [userInfo objectForKey:@"identifier"];
        [self.dataSource refreshCell:actionType identifier:identifier];
    }
}
#pragma mark - Privare
- (void)onLeftNavClick:(id)sender {
    
}
- (void)onRightNavClick:(id)sender {
    
}

#pragma mark - TFTableViewDataSourceDelegate

- (void)didStartLoad {
    [self showStateView:kTFViewStateLoading];
}


- (void)actionOnView:(TFTableViewItem *)item actionType:(NSInteger)actionType {
    
}

- (void)didFinishLoad:(TFDataLoadPolicy)loadPolicy object:(id)object error:(NSError *)error {
    if (!error) {
        [self removeStateView];
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
            [self showStateView:state];
        }
        else {
            [self showStateView:kTFViewStateDataError];
        }
    }
}

- (BOOL)showPullRefresh {
    return _usePullReload;
}

- (CGPoint)offsetForStateView:(UIView *)view {
    return CGPointMake(0, 0);
}

- (void)scrollViewDidScroll:(UITableView *)tableView {
    
    CGFloat currentPostion = tableView.contentOffset.y;
    if (currentPostion - lastPosition > 30) {
        lastPosition = currentPostion;
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
    else if (lastPosition - currentPostion > 30) {
        lastPosition = currentPostion;
    }
}
- (void)scrollViewDidScrollUp:(CGFloat)deltaY {
    [self moveTabBar:-deltaY animated:YES];
}

- (void)scrollViewDidScrollDown:(CGFloat)deltaY {
    [self moveTabBar:-deltaY animated:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp {
    [self hideTabBar:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown {
    [self showTabBar:YES];
}

@end
