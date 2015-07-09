//
//  BUKViewController.m
//  BUKCollectionFlowView
//
//  Created by huhuhumian on 07/06/2015.
//  Copyright (c) 2015 huhuhumian. All rights reserved.
//

#import "BUKViewController.h"

@interface BUKViewController ()

@end

@implementation BUKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _collectionFlowView = [[BUKCollectionFlowView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200) contentData:@[@"aaa",@"aaaaaaa",@"aaaaa",@"aaaaaa",@"aaaaaaaa"] collectionViewType:BUKCollectionFlowViewTypeEditable];
//    _collectionFlowView.width = [UIScreen mainScreen].bounds.size.width;
    [self.view addSubview:_collectionFlowView];
    [_collectionFlowView showCertainLines:2 showMore:NO moreTag:@"更多..."];
//    [_collectionFlowView setUp];
    [_collectionFlowView setDeleteAction:^(NSInteger index, NSString *deleteItem){
//        NSLog(@"%f", [_collectionFlowView getHeight]);
    }];
    __weak typeof(BUKCollectionFlowView) *weakCollectionView = _collectionFlowView;
    [_collectionFlowView setClickAction:^(NSInteger index, NSString *clickItem) {
        [weakCollectionView addItem:@"bbb"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
