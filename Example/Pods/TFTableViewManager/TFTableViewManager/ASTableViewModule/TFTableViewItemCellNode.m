//
//  TFTableViewItemCellNode.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/9/5.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewItemCellNode.h"
#import "TFTableViewItem.h"

@implementation TFTableViewItemCellNode

+ (CGFloat)cellNodeHeightWithItem:(TFTableViewItem *)item {
    return item.cellHeight? :0.0;
}

- (instancetype)initWithTableViewItem:(TFTableViewItem *)tableViewItem {
    self = [super init];
    if (self) {
        self.tableViewItem = tableViewItem;
        self.selectionStyle = self.tableViewItem.selectionStyle;
        self.accessoryType = self.tableViewItem.accessoryType;
        self.separatorInset = self.tableViewItem.separatorInset;
    }
    [self cellLoadSubNodes];
    return self;
}

- (void)cellLoadSubNodes {
    
}


@end
