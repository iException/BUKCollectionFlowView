//
//  BUKCollectionFlowView.h
//  Baixing
//
//  Created by humian on 15/7/2.
//  Copyright (c) 2015年 baixing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BUKCollectionFlowViewTypeNormal,
    BUKCollectionFlowViewTypeDeletable,
    BUKCollectionFlowViewTypeEditable,
} BUKCollectionFlowViewType;

@interface BUKCollectionFlowView : UIView

@property (nonatomic, strong) UIColor *foreColor;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) NSArray *contents;

@property (nonatomic, strong) UIImage *tagDeleteIcon;

@property (nonatomic, strong) UIImage *tagAddIcon;

@property (nonatomic, assign) NSInteger lineSpacing;

@property (nonatomic, assign) NSInteger interitemSpacing;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) CGFloat width;

@property (copy, nonatomic) void (^clickAction)(NSInteger index, NSString *clickItem);

@property (copy, nonatomic) void (^deleteAction)(NSString *deleteItem, CGFloat heightAfterDelete);

- (instancetype)initWithFrame:(CGRect)frame contentData:(NSArray *)content collectionViewType:(BUKCollectionFlowViewType)type;

- (void)showCertainLines:(NSInteger)numberOfLines showMore:(BOOL)showMore moreTag:(NSString *)moreTag;

- (CGFloat)getHeight;

- (void)addItem:(NSString *)content;

- (void)setUp;

@end
