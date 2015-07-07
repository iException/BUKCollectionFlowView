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

@interface BUKCollectionFlowView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BUKCollectionFlowViewType viewType;

@property (nonatomic, assign) BOOL showMore;

@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, strong) NSString *moreTag;

@property (nonatomic, strong) BUKLeftAlignedCollectionViewFlowLayout *layout;

@end

@implementation BUKCollectionFlowView

- (instancetype)initWithFrame:(CGRect)frame contentData:(NSArray *)content collectionViewType:(BUKCollectionFlowViewType)type
{
    self = [self initWithFrame:frame collectionViewLayout:self.layout];
    self.viewType = type;
    
    [self registerClass:[BUKCollectionFlowViewCell class] forCellWithReuseIdentifier:@"collectionFlowViewCell"];
    
    self.foreColor = [UIColor whiteColor];
    self.lineColor = [UIColor colorWithRed:0xf0/255.0 green:0xf0/255.0 blue:0xf0/255.0 alpha:1.0f];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contents = content;
        self.dataSource = self;
        self.delegate = self;
    }
    
    return self;
}

- (void)showCertainLines:(NSInteger)numberOfLines showMore:(BOOL)showMore moreTag:(NSString *)moreTag
{
    _numberOfLines = numberOfLines;
    _showMore = showMore;
    _moreTag = moreTag;
    [self reloadData];
}

- (void)showAll
{
    _numberOfLines = 0;
    [self reloadData];
}

- (CGFloat)getHeight
{
    NSInteger lineCount = 0;
    CGSize firstTagSize = [self collectionView:self
                                layout:_layout
                sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGFloat lineHeight = firstTagSize.height;
    
    if ( _numberOfLines && _numberOfLines>0 )
    {
        lineCount = _numberOfLines;
    } else {
        lineCount = [self getLineNumber];
    }
    return (lineHeight+_layout.minimumInteritemSpacing)*lineCount-_layout.minimumInteritemSpacing;
}

- (void)applyConfig
{
    _layout.minimumLineSpacing = _lineSpacing ? _lineSpacing:8;
    _layout.minimumInteritemSpacing = _interitemSpacing ? _interitemSpacing:10;
    
    self.collectionViewLayout = _layout;
    
    [self reloadData];
}

- (void)addItem:(NSString *)content
{
    NSMutableArray *array = [_contents mutableCopy];
    [array addObject:content];
    _contents = [array copy];
    [self reloadData];
}

#pragma mark - collectionView data source

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.clickAction) {
        self.clickAction(indexPath);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BUKCollectionFlowViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"collectionFlowViewCell"
                                                                     forIndexPath:indexPath];
    cell.indexPath = indexPath;
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeNormal:
            [cell fillWithContent:[self safeObjectAtIndexInContents:indexPath.row]
                         cellType:BUKCollectionFlowViewCellTypeNormal];
            break;
            
        case BUKCollectionFlowViewTypeDeletable:
            [cell fillWithContent:[self safeObjectAtIndexInContents:indexPath.row]
                         cellType:BUKCollectionFlowViewCellTypeDeletable];
            break;
            
        case BUKCollectionFlowViewTypeEditable:
            if (indexPath.row==0) {
                [cell fillWithContent:nil cellType:BUKCollectionFlowViewCellTypeAdd];
            } else {
                [cell fillWithContent:[self safeObjectAtIndexInContents:indexPath.row-1]
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
    cell.label.font = _font ? _font:[UIFont systemFontOfSize:17];
    [cell.deleteButton setImage:_tagDeleteIcon forState:UIControlStateNormal];
    [cell.addButton setImage:_tagAddIcon forState:UIControlStateNormal];
    [cell setDeleteAction:^(NSIndexPath *indexPath) {
        [self didDeleteButtonClick:indexPath];
    }];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( _numberOfLines || _numberOfLines>0 ) {
        [self reduceContentToFit];
    }
    if (self.contents){
        return self.viewType==BUKCollectionFlowViewTypeEditable ? [self.contents count]+1:[self.contents count];
    } else {
        return self.viewType==BUKCollectionFlowViewTypeEditable ? 1:0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.contents || self.contents.count == 0) {
        return CGSizeMake(0, 0);
    }
    
    UILabel *label = [[UILabel alloc] init];
    if (_font) {
        label.font = _font;
    }
    label.text = [self safeObjectAtIndexInContents:indexPath.row];
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
            if (indexPath.row==0) {
                itemWidth = itemHeight;
            } else {
                label.text = [self safeObjectAtIndexInContents:indexPath.row-1];
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

- (void)didDeleteButtonClick:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [_contents mutableCopy];
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeDeletable:
            [array removeObjectAtIndex:indexPath.row];
            break;
            
        case BUKCollectionFlowViewTypeEditable:
            [array removeObjectAtIndex:indexPath.row-1];
            break;
            
        default:
            break;
    }
    _contents = [array copy];
    [self reloadData];
}

- (void)reduceContentToFit
{
    NSInteger count = 0;
    CGFloat widthSum = 0;
    
    CGSize firstTagSize = [self collectionView:self
                                layout:_layout
                sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGSize selfFitSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    if ( selfFitSize.height+_layout.minimumInteritemSpacing >= (firstTagSize.height+_layout.minimumInteritemSpacing)*_numberOfLines )
    {
        return;
    }
    
    for (int i=1; i<_numberOfLines; i++)
    {
        widthSum = 0;
        while ( widthSum <= _width && count<[_contents count]){
            CGSize size = [self collectionView:self
                                        layout:_layout
                        sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]];
            widthSum = widthSum+size.width+_layout.minimumLineSpacing;
            count++;
        }
        if (widthSum > _width)
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
        
        widthSum = labelSize.width+20+_layout.minimumLineSpacing;
    } else {
        widthSum = 0;
    }
    while ( widthSum <= _width && count<[_contents count]){
        CGSize size = [self collectionView:self
                                    layout:_layout
                    sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]];
        widthSum = widthSum+size.width+_layout.minimumLineSpacing;
        count++;
    }
    if (widthSum > _width)
    {
        count--;
    } else {
        return;
    }
    NSMutableArray *array = [_contents mutableCopy];
    switch (self.viewType) {
        case BUKCollectionFlowViewTypeEditable:
            [array removeObjectsInRange:NSMakeRange(count-1, [_contents count]-count+1)];
            break;
            
        default:
            [array removeObjectsInRange:NSMakeRange(count, [_contents count]-count)];
            break;
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
    while (true)
    {
        lineCount++;
        widthSum = 0;
        while ( widthSum <= _width && count<[_contents count]){
            CGSize size = [self collectionView:self
                                        layout:_layout
                        sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]];
            widthSum = widthSum+size.width+_layout.minimumLineSpacing;
            count++;
        }
        if (widthSum > _width)
        {
            count--;
        } else {
            return lineCount;
        }
    }
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

- (BUKLeftAlignedCollectionViewFlowLayout *)layout
{
    if ( !_layout )
    {
        _layout = [[BUKLeftAlignedCollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 8;
        _layout.minimumInteritemSpacing = 10;
    }
    return _layout;
}

@end
