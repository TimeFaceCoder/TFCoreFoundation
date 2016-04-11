//
//  TFTableViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"
@class ASTableView;
@class TFTableViewDataSource;

@interface TFTableViewController : TFViewController

@property (nonatomic ,strong ,readonly) ASTableView *tableView;
@property (nonatomic ,assign) UITableViewStyle      tableViewStyle;
@property (nonatomic ,strong ,readonly) TFTableViewDataSource *dataSource;
@property (nonatomic ,assign) NSInteger             listType;
@property (nonatomic ,assign) BOOL                  usePullReload;

@end
