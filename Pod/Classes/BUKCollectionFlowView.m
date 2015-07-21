//
//  BXCollectionFlowView.m
//  Baixing
//
//  Created by humian on 15/7/2.
//  Copyright (c) 2015年 baixing. All rights reserved.
//

#import "BUKCollectionFlowView.h"
#import "BUKCollectionFlowViewCell.h"
#import "BUKLeftAlignedCollectionViewFlowLayout.h"

@interface BUKCollectionFlowView()

@property (nonatomic, assign) BUKCollectionFlowViewType viewType;

@property (nonatomic, assign) BOOL showMore;

@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, strong) NSString *moreTag;

@end

@implementation BUKCollectionFlowView

- (instancetype)initWithFrame:(CGRect)frame contentData:(NSArray *)content collectionViewType:(BUKCollectionFlowViewType)type
{
    self = [self initWithFrame:frame];
    
    if (self) {
        self.viewType = type;
        
        self.foreColor = [UIColor whiteColor];
        self.lineColor = [UIColor colorWithRed:0xf0/255.0 green:0xf0/255.0 blue:0xf0/255.0 alpha:1.0f];
        self.textColor = [UIColor blackColor];
        self.lineSpacing = 8;
        self.interitemSpacing = 10;
        
        self.backgroundColor = [UIColor clearColor];
        _contents = [content copy];
    }
    
    return self;
}

- (void)showCertainLines:(NSInteger)numberOfLines showMore:(BOOL)showMore moreTag:(NSString *)moreTag
{
    _numberOfLines = numberOfLines;
    _showMore = showMore;
    _moreTag = moreTag;
    [self reduceContentToFit];
    [self setUp];
}

- (CGFloat)getHeight
{
    NSInteger lineCount = 0;
    CGSize firstTagSize = [self cellSizeForIndex:0];
    CGFloat lineHeight = firstTagSize.height;
    
    lineCount = [self getLineNumber];
    
    return (lineHeight+_interitemSpacing)*lineCount-_interitemSpacing;
}

- (void)addItem:(NSString *)content
{
    NSMutableArray *array = [_contents mutableCopy];
    [array addObject:content];
    _contents = [array copy];
    [self setUp];
}

- (void)setUp
{
    if ( _width==0 && self.frame.size.width==0 )
    {
        return;
    }
    
    for (UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    
    __block BUKCollectionFlowViewCell *preCell = nil;
    __block CGFloat widthSum = 0;
    _width = _width==0 ? self.frame.size.width : _width;
    if (self.viewType == BUKCollectionFlowViewTypeEditable)
    {
        BUKCollectionFlowViewCell *firstCell = [self cellForIndex:0];
        [self addSubview:firstCell];
        firstCell.frame = CGRectMake(0, 0, [self cellSizeForIndex:0].width, [self cellSizeForIndex:0].height);
        preCell = firstCell;
        widthSum = [self cellSizeForIndex:0].width;
    }
    if ( _contents == nil || [_contents count]==0 )
    {
        return;
    }
    [_contents enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop) {
        BUKCollectionFlowViewCell *cell;
        CGSize size;
        if (self.viewType == BUKCollectionFlowViewTypeEditable)
        {
            cell = [self cellForIndex:idx+1];
            size = [self cellSizeForIndex:idx+1];
        } else {
            cell = [self cellForIndex:idx];
            size = [self cellSizeForIndex:idx];
        }
        [self addSubview:cell];
        if ( widthSum+_lineSpacing+size.width > _width )
        {
            CGFloat celly = preCell ? preCell.frame.origin.y + preCell.frame.size.height + _interitemSpacing : 0;
            cell.frame = CGRectMake(0, celly, size.width, size.height);
            widthSum = size.width;
        } else {
            if (self.enableSeperator && preCell) {
                CGFloat height = cell.label.font.lineHeight * 0.8;
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(preCell.frame)+_lineSpacing/2.0, CGRectGetMidY(preCell.frame) - height/2.0, 1, height)];
                line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
                [self addSubview:line];
            }

            CGFloat cellx = preCell ? preCell.frame.origin.x + preCell.frame.size.width + _lineSpacing : 0;
            cell.frame = CGRectMake(cellx, preCell.frame.origin.y, size.width, size.height);
            widthSum = widthSum+_lineSpacing+size.width;
        }
        preCell = cell;
    }];
}

- (void)didClickCell:(UITapGestureRecognizer *)gesture
{
    if ([gesture.view isKindOfClass:[BUKCollectionFlowViewCell class]])
    {
        BUKCollectionFlowViewCell *cell = (BUKCollectionFlowViewCell *)gesture.view;
        NSInteger index = cell.index;
        if (self.clickAction) {
            if (self.viewType == BUKCollectionFlowViewTypeEditable) {
                self.clickAction(index, index==0 ? nil:[self safeObjectAtIndexInContents:index-1]);
            } else {
                self.clickAction(index, [self safeObjectAtIndexInContents:index]);
            }
        }
    }
}

- (BUKCollectionFlowViewCell *)cellForIndex:(NSInteger)index;
{
    BUKCollectionFlowViewCell *cell = [[BUKCollectionFlowViewCell alloc] init];
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeNormal:
            [cell fillWithContent:[self safeObjectAtIndexInContents:index]
                         cellType:BUKCollectionFlowViewCellTypeNormal];
            break;
            
        case BUKCollectionFlowViewTypeDeletable:
            [cell fillWithContent:[self safeObjectAtIndexInContents:index]
                         cellType:BUKCollectionFlowViewCellTypeDeletable];
            break;
            
        case BUKCollectionFlowViewTypeEditable:
            if (index==0) {
                [cell fillWithContent:nil cellType:BUKCollectionFlowViewCellTypeAdd];
            } else {
                [cell fillWithContent:[self safeObjectAtIndexInContents:index-1]
                             cellType:BUKCollectionFlowViewCellTypeDeletable];
            }
            break;
            
        default:
            break;
    }
    cell.backgroundColor = self.foreColor;
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = self.lineColor.CGColor;
    cell.index = index;
    cell.label.font = _font ? _font:[UIFont systemFontOfSize:17];
    cell.label.textColor = _textColor;
    if (_tagDeleteIcon)
    {
        [cell.deleteButton setImage:_tagDeleteIcon forState:UIControlStateNormal];
    }
    if (_tagAddIcon)
    {
        [cell.addButton setImage:_tagAddIcon forState:UIControlStateNormal];
    }
    [cell setDeleteAction:^(NSInteger index) {
        [self didDeleteButtonClick:index];
        if (self.deleteAction)
        {
            if (self.viewType == BUKCollectionFlowViewTypeEditable) {
                self.deleteAction(index, [self safeObjectAtIndexInContents:index-1]);
            } else {
                self.deleteAction(index, [self safeObjectAtIndexInContents:index]);
            }
        }
    }];
    
    cell.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickCell:)];
    [cell addGestureRecognizer:singleTap];
    
    return cell;
}

- (CGSize)cellSizeForIndex:(NSInteger)index
{
    if ( self.viewType==BUKCollectionFlowViewTypeEditable && index==0 )
    {
        UILabel *label = [[UILabel alloc] init];
        if (_font) {
            label.font = _font;
        }
        label.text = @"啊";
        CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return CGSizeMake(labelSize.height+10, labelSize.height+10);
    }
    
    if (!self.contents || self.contents.count == 0) {
        return CGSizeMake(0, 0);
    }
    
    UILabel *label = [[UILabel alloc] init];
    if (_font) {
        label.font = _font;
    }
    label.text = [self safeObjectAtIndexInContents:index];
    CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    CGFloat itemWidth = labelSize.width+20;
    CGFloat itemHeight = labelSize.height+10;
    
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeNormal:
            break;
            
        case BUKCollectionFlowViewTypeDeletable:
            itemWidth = itemWidth+labelSize.height;
            break;
            
        case BUKCollectionFlowViewTypeEditable:
            if (index==0) {
                itemWidth = itemHeight;
            } else {
                label.text = [self safeObjectAtIndexInContents:index-1];
                CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                
                itemWidth = labelSize.width+labelSize.height+20;
                itemHeight = labelSize.height+10;
            }
            break;
            
        default:
            break;
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - block method

- (void)didDeleteButtonClick:(NSInteger)index
{
    NSMutableArray *array = [_contents mutableCopy];
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeDeletable:
            [array removeObjectAtIndex:index];
            break;
            
        case BUKCollectionFlowViewTypeEditable:
            [array removeObjectAtIndex:index-1];
            break;
            
        default:
            break;
    }
    _contents = [array copy];
    [self setUp];
}

- (void)reduceContentToFit
{
    NSInteger count = 0;
    CGFloat widthSum = 0;
    
    CGSize firstTagSize = [self cellSizeForIndex:0];
    
    if ( [self getHeight]+_interitemSpacing <= (firstTagSize.height+_interitemSpacing)*_numberOfLines )
    {
        return;
    }
    
    for (int i=1; i<_numberOfLines; i++)
    {
        widthSum = 0;
        while ( widthSum <= _width+_lineSpacing && count<[_contents count]){
            CGSize size = [self cellSizeForIndex:count];
            widthSum = widthSum+size.width+_lineSpacing;
            count++;
        }
        if (widthSum > _width+_lineSpacing)
        {
            count--;
        } else {
            return;
        }
    }
    if (_showMore){
        UILabel *label = [[UILabel alloc] init];
        if (_font) {
            label.font = _font;
        }
        label.text = _moreTag;
        CGSize labelSize = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        widthSum = labelSize.width+20+_lineSpacing;
    } else {
        widthSum = 0;
    }
    while ( widthSum <= _width+_lineSpacing && count<(self.viewType == BUKCollectionFlowViewTypeEditable? [_contents count]+1:[_contents count])){
        CGSize size = [self cellSizeForIndex:count];
        widthSum = widthSum+size.width+_lineSpacing;
        count++;
    }
    if (widthSum > _width+_lineSpacing)
    {
        count--;
    } else {
        return;
    }
    NSMutableArray *array = [_contents mutableCopy];
    if( self.viewType == BUKCollectionFlowViewTypeEditable)
    {
        [array removeObjectsInRange:NSMakeRange(count-1, [_contents count]-count+1)];
    } else {
        [array removeObjectsInRange:NSMakeRange(count, [_contents count]-count)];
    }
    if (_showMore)
    {
        [array addObject:_moreTag];
    }
    _contents = [array copy];
}

- (NSInteger)getLineNumber
{
    NSInteger count = 0;
    CGFloat widthSum = 0;
    NSInteger lineCount = 0;
    _width = _width==0 ? self.frame.size.width : _width;
    while ( _width && _width>=[self cellSizeForIndex:count].width )
    {
        lineCount++;
        widthSum = 0;
        if ( !_width || _width==0 )
        {
            return 0;
        }
        while ( widthSum <= _width+_lineSpacing
               && count<(self.viewType==BUKCollectionFlowViewTypeEditable? [_contents count]+1:[_contents count]) ){
            CGSize size = [self cellSizeForIndex:count];
            widthSum = widthSum+size.width+_lineSpacing;
            count++;
        }
        if ( widthSum > _width+_lineSpacing )
        {
            count--;
        } else {
            return lineCount;
        }
    }
    return 0;
}

- (id)safeObjectAtIndexInContents:(NSUInteger)index
{
    NSAssert([_contents isKindOfClass:[NSArray class]], @"object is not an array");
    
    NSUInteger emptysize = 0;
    
    if (NO == [_contents isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (emptysize > index || index >= [(NSArray *)_contents count]) {
        return nil;
    }
    
    id object = [(NSArray *)_contents objectAtIndex:index];
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return object;
}

#pragma mark - getter & setter - 

- (void)setContents:(NSArray *)contents
{
    _contents = [contents copy];
    [self setUp];
}

@end
