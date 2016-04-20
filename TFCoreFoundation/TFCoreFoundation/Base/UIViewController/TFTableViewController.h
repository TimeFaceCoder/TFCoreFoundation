//
//  TFTableViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"
#import <TFTableViewDataSource/TFTableViewDataSource.h>

@interface TFTableViewController : TFViewController <TFTableViewDataSourceDelegate>

@property (nonatomic ,strong ,readonly) ASTableView *tableView;
@property (nonatomic ,assign) UITableViewStyle      tableViewStyle;
@property (nonatomic ,strong ,readonly) TFTableViewDataSource *dataSource;
@property (nonatomic ,assign) NSInteger             listType;
@property (nonatomic ,assign) BOOL                  usePullReload;

@end
