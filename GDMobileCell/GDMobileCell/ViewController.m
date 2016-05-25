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

static UIView *snapedView;
static NSIndexPath *currenIndexPath;
static NSIndexPath *oldIndexPath;
static UIView *view;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //添加collectionView
    [self.view addSubview:self.collectionView];
    
    _dataSource = [NSMutableArray array];
    for (int i = 0; i <= 30; i++) {
        CGFloat hue  = (arc4random() % 256 / 256.0f);
        CGFloat saturation = (arc4random() % 128 / 256.0f) + 0.5;
        CGFloat brightness = (arc4random() % 128 / 256.0f) + 0.5;
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8];
        [_dataSource addObject:color];
    }
    
}
#pragma mark -- Listening to the gestures Mobile the cell
-(void)ListeningGestures:(UILongPressGestureRecognizer *)longGesture{
    
    if (IOS_VERSION < 9.0) {
        //IOS9之前
        [self VersionBefore:longGesture];
    }else{
        //IOS9以上版本
        [self VersionAfter:longGesture];
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

#pragma mark -- Function implementation
/***********************版本之前************************/

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动,这步非常关键
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    
    //取出item数据作更新
    id item = [_dataSource objectAtIndex:sourceIndexPath.item];
    //从数组中移除旧的item
    [_dataSource removeObject:item];
    //再将新的item重新放入数组
    [_dataSource insertObject:item atIndex:destinationIndexPath.item];
}

-(void)VersionBefore:(UILongPressGestureRecognizer *)longGesture{
    
    switch (longGesture.state) {
            //手势开始
        case UIGestureRecognizerStateBegan:
        {
            //判断手势落点位置是否在item上
            oldIndexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (!oldIndexPath) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
            //使用系统截图，获得cell截的视图
            snapedView = [cell snapshotViewAfterScreenUpdates:NO];
            snapedView.frame = cell.frame;
            [self.collectionView addSubview:snapedView];
            
            //截图后隐藏当前cell
            cell.hidden = YES;
            CGPoint currenPoint = [longGesture locationInView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
                snapedView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                snapedView.center = CGPointMake(currenPoint.x, currenPoint.y);
            }];
        }
            break;
            
            //手势改变
        case UIGestureRecognizerStateChanged:
        {
            //当前手指位置 所截的视图位置移动
            CGPoint currenPoint = [longGesture locationInView:self.collectionView];
            snapedView.center = CGPointMake(currenPoint.x, currenPoint.y);
            
            //计算截图视图与将要交换item
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //当前隐藏的cell就不需要交换 直接continue
                if ([self.collectionView indexPathForCell:cell] == oldIndexPath) {
                    
                    continue;
                }
                CGFloat space = sqrt(pow(snapedView.center.x - cell.center.x, 2) + powf(snapedView.center.y - cell.center.y, 2));
                //如果相交一半就移动
                if (space <= snapedView.bounds.size.width / 2) {
                    currenIndexPath = [self.collectionView indexPathForCell:cell];
                    //移动 会调用willMoveToIndexPath方法更新数据源
                    [self.collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:currenIndexPath];
                    //设置移动后的起始indexPath
                    oldIndexPath = currenIndexPath;
                    break;
                }
            }
        }
            break;
            
            
        default:
        {
            //手势结束和其他手势
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
            //结束动画过程中停止交互，防止出现问题
            self.collectionView.userInteractionEnabled = NO;
            //给截图视图一个动画移动到隐藏cell 新的位置
            [UIView animateWithDuration:0.25 animations:^{
                snapedView.center = cell.center;
                snapedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            }completion:^(BOOL finished) {
                //移除截图视图、显示隐藏cell并开启交互
                [snapedView removeFromSuperview];
                cell.hidden = NO;
                self.collectionView.userInteractionEnabled = YES;
            }];
        }
            break;
    }
}
/***********************版本之后************************/
-(void)VersionAfter:(UILongPressGestureRecognizer *)longGesture{
    
    switch (longGesture.state) {
            //手势开始
        case UIGestureRecognizerStateBegan:
        {
            //判断手势落点位置是否在item上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [self.collectionView bringSubviewToFront:cell];
            //在item上则开始移动该itme的cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
            //手势改变
        case UIGestureRecognizerStateChanged:
        {
            //移动过程当中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collectionView]];
            
        }
            break;
            //手势结束
        case UIGestureRecognizerStateEnded:
        {
            //移动结束后关闭cell移动
            [self.collectionView endInteractiveMovement];
        }
            break;
            //其他手势状态
        default:
        {
            [self.collectionView cancelInteractiveMovement];
        }
            break;
    }
}

#pragma mark -- Item Zoom in on
-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPatt{
    
    if (IOS_VERSION >= 9) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark --Item Zoom in on implementation
/***********************放大缩小效果************************/

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView bringSubviewToFront:selectedCell];
    [UIView animateWithDuration:0.28 animations:^{
        selectedCell.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.28 animations:^{
        selectedCell.transform  =CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

/***********************懒加载************************/
#pragma mark -- Lazy loading
-(UICollectionView *)collectionView{
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((WIDTH - 15)/3, (WIDTH - 15)/3);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 20, WIDTH, HEIGHT - 20) collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        //添加长按手势
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ListeningGestures:)];
        //触发时间
        longGesture.minimumPressDuration = 0.5f;
        [_collectionView addGestureRecognizer:longGesture];
    }
    return _collectionView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
