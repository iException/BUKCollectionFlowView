//
//  BUKCollectionFlowViewCell.h
//  Baixing
//
//  Created by humian on 15/7/6.
//  Copyright (c) 2015年 baixing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BUKCollectionFlowViewCellTypeNormal,
    BUKCollectionFlowViewCellTypeDeletable,
    BUKCollectionFlowViewCellTypeAdd,
} BUKCollectionFlowViewCellType;

@interface BUKCollectionFlowViewCell : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIImage *deleteIcon;

@property (nonatomic, strong) UIImage *addIcon;

@property (copy, nonatomic) void (^deleteAction)(NSInteger index);

- (void)fillWithContent:(NSString *)content cellType:(BUKCollectionFlowViewCellType)type;

@end
