//
//  ViewController.m
//  GDMobileCell
//
//  Created by gdarkness on 16/5/24.
//  Copyright © 2016年 gdarkness. All rights reserved.
//

#import "ViewController.h"
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height
//获取当前系统版本
#define IOS_VERSION [[[UIDevice currentDevice]systemVersion]floatValue]

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *_dataSource;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //添加collectionView
    [self.view addSubview:self.collectionView];
    
    _dataSource = [NSMutableArray array];
    for (int i = 0; i <= 50; i++) {
        CGFloat hue  = (arc4random() % 256 / 256.0f);
        CGFloat saturation = (arc4random() % 128 / 256.0f) + 0.5;
        CGFloat brightness = (arc4random() % 128 / 256.0f) + 0.5;
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8];
        [_dataSource addObject:color];
    }
    
}
#pragma mark -- Listening to the gestures Mobile the cell
-(void)ListeningGestures:(UILongPressGestureRecognizer *)listeningGestures{
    
    if (IOS_VERSION < 9.0) {
        //IOS9之前
    }else{
        //IOS9以上版本
    }
}

#pragma mark -- UICollectionView Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPat{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPat];
    cell.backgroundColor = _dataSource[indexPat.item];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
