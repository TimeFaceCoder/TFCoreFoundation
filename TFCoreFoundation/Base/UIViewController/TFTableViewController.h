//
//  TFTableViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"
#import <TFTableViewDataSource/TFTableViewDataSource.h>

extern NSString * const kTFTableViewTypeKey;
extern NSString * const kTFTableViewStyleKey;
extern NSString * const kTFTableViewListTypeKey;
extern NSString * const kTFTableViewUsePullReloadKey;

/**
 *  tableview类型
 */
typedef NS_ENUM(NSInteger, TFTableViewType) {
    /**
     *  UITableview类型
     */
    TFTableViewTypeUITableView,
    /**
     *  ASTableNode类型
     */
    TFTableViewTypeASTableNode,
};

/**
 *  a view controller to create table view fast.
 */
@interface TFTableViewController : TFViewController <TFTableViewDataSourceDelegate>

/**
 *  @brief the tableView type of viewController, default is TFTableViewTypeASTableNode.
 */
@property (nonatomic ,assign) TFTableViewType tableViewType;

/**
 *  @brief an UITableView that is create by ViewController automatically.
 */
@property (nonatomic ,strong ,readonly) UITableView *tableView;

/**
 *  @brief an ASTableNode that is craete by ViewController automatically.
 */
@property (nonatomic ,strong ,readonly) ASTableNode *tableNode;

/**
 *  @brief tableView style, default is UITableViewStylePlain.
 */
@property (nonatomic ,assign) UITableViewStyle tableViewStyle;

/**
 *  @brief data source of ViewController.
 */
@property (nonatomic ,strong ,readonly) TFTableViewDataSource *dataSource;

/**
 *  @brief request params of the request in tableview.
 */
@property (nonatomic ,strong) NSMutableDictionary *requestParams;

/**
 *  @brief other request want to be load when load the data.
 */
@property (nonatomic, strong) NSArray *batchRequestArr;
/**
 *  @brief other request should be load when data request is load the data of first page, default is YES.
 */
@property (nonatomic, assign) BOOL batchShouldLoadInFirstPage;

/**
 *  @brief list type which is associated with TFTableViewDataManager,TFTableViewDataSource,RequestUrl.
 */
@property (nonatomic ,assign) NSInteger listType;

/**
 *  @brief use pull Reload or not, default is YES.
 */
@property (nonatomic ,assign) BOOL usePullReload;

/**
 *  start load data, set the requestParams firstly.
 */
- (void)startLoadData;

/**
 reload data source by new list type and params.

 @param listType new list type.
 @param params   new params.
 */
- (void)reloadDataSourceWith:(NSInteger)listType params:(NSDictionary *)params;

/**
 register url,listype,dataManager to view controller.
 */
- (void)setupListTypeUrlRelation;


@end
