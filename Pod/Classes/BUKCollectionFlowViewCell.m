//
//  BUKCollectionFlowViewCell.m
//  Baixing
//
//  Created by humian on 15/7/6.
//  Copyright (c) 2015年 baixing. All rights reserved.
//

#import "BUKCollectionFlowViewCell.h"

@interface BUKCollectionFlowViewCell()

@end

@implementation BUKCollectionFlowViewCell

- (void)fillWithContent:(NSString *)content cellType:(BUKCollectionFlowViewCellType)type
{
    if (self) {
        if (content){
            self.label.text = content;
            [self addSubview:_label];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_label]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_label]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
        }
        switch (type) {
            case BUKCollectionFlowViewCellTypeNormal:
                break;
                
            case BUKCollectionFlowViewCellTypeDeletable:
                [self addSubview:self.deleteButton];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_deleteButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_deleteButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_label]-0-[_deleteButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label,_deleteButton)]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_deleteButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_deleteButton)]];
                break;
                
            case BUKCollectionFlowViewCellTypeAdd:
                [self addSubview:self.addButton];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_addButton]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_addButton)]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_addButton]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_addButton)]];
                break;
                
            default:
                break;
        }
        
        
    }
}

- (void)prepareForReuse
{
    for (UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
}

#pragma mark - button click

- (void)deleteButtonClick:(id)sender
{
    if (self.deleteAction)
    {
        self.deleteAction(self.index);
    }
}

#pragma mark - getter & setter

- (UILabel *)label
{
    if (_label == nil)
    {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _label;
}

- (UIButton *)deleteButton
{
    if (_deleteButton == nil)
    {
        _deleteButton = [[UIButton alloc] init];
        _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setImage:[UIImage imageNamed:@"tag_delete"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

- (UIButton *)addButton
{
    if (_addButton == nil)
    {
        _addButton = [[UIButton alloc] init];
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
        _addButton.userInteractionEnabled = NO;
        [_addButton setImage:[UIImage imageNamed:@"tag_add"] forState:UIControlStateNormal];
    }
    return _addButton;
}

@end
