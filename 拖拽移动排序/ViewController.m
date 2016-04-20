//
//  ViewController.m
//  拖拽移动排序
//
//  Created by lixiya on 15/9/9.
//  Copyright (c) 2015年 lixiya. All rights reserved.
//

#define KBase_tag     100
#define IphoneWidth   [UIScreen mainScreen].bounds.size.width
#define IphoneHeight  [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"

@interface ViewController (){
    
    NSInteger totalNumber;
    
    // 开始拖动的view的下一个view的CGPoint（如果开始位置是0 结束位置是4 nextPoint值逐个往下算）
    CGPoint nextPoint;
    
    // 用于赋值CGPoint
    CGPoint valuePoint;
    
    
}

@end

@implementation ViewController
/**
 *  实现思路：给按钮添加拖拽或者长按手势，根据按钮的偏移量更新按钮的位置，然后再根据移动的点的CGPoint是否移动到了其他view的位置来更新其他view的位置

 *  按照这个思路可以做类似支付宝首页 网易新闻选项卡界面的动态删除和添加
 */

// 知识点
/**
 * translationInView（UIPanGestureRecognizer） 拖拽视图在父视图上的偏移量
 * locationInView:(UIView*)view（UIGestureRecognizer）长按触摸点在view中的位置
 */


/**
 *  1.initWithCapacity:10 并不代表里面的object数量不能大于10.也可以大于10.
 *  2.init是在告诉程序，“我不知道要放多少object,暂且帮我初始化”。
 *  3.如果你知道大概要放多少东西，那么最好用initWithCapacity,这个会提高程序内存运用效率。
 */


- (void)viewDidLoad {
    self.title = @"点击按钮可以删除，长按排序";
    [super viewDidLoad];
    totalNumber = 9;

    
    // 创建9宫格
    CGFloat btW = (IphoneWidth-20*4)/3;
    CGFloat btH = btW;
    
    for (NSInteger i = 0; i<totalNumber; i++) {
        
        UIButton * bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.frame = CGRectMake(20+(20+btW)*(i%3), 100 + (i/3)*(btH+20), btW, btH);
        bt.backgroundColor = [UIColor redColor];
        bt.tag = KBase_tag+i;
        [bt setTitle:[NSString stringWithFormat:@"tag值%ld",bt.tag] forState:UIControlStateNormal];
        [bt addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bt];
        
        // 添加拖拽手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [pan setMaximumNumberOfTouches:1]; // 最小手指数
        [pan setMaximumNumberOfTouches:2]; // 最大手指数
        //[bt addGestureRecognizer:pan];
        
        // 长按手势
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [bt addGestureRecognizer:longPress];
    }
    
    
    // 添加按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(doAdd)];
    
    
    // 
}

/**
 *  添加
 */
-(void)doAdd{
    CGFloat btW = (IphoneWidth-20*4)/3;
    CGFloat btH = btW;
    
    totalNumber++;
    NSInteger btIndex = totalNumber-1;
    
    UIButton * bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame = CGRectMake(20+(20+btW)*(btIndex%3), 100 + (btIndex/3)*(btH+20), btW, btH);
    bt.backgroundColor = [UIColor redColor];
    bt.tag = KBase_tag+btIndex;
    [bt setTitle:[NSString stringWithFormat:@"tag值%ld",bt.tag] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];
    
    // 长按手势
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [bt addGestureRecognizer:longPress];

    
}

/**
 * 点击按钮删除该项
 */

-(void)doDelete:(UIButton*)bt{
    
    // 需要移除的view的位置
    CGPoint btPoint = bt.center;
    NSInteger btIndex  = bt.tag - KBase_tag;
    
    // 移除view
    [bt removeFromSuperview];
    
    // 把需要删除view的下一个view移动到记录的view的位置(valuePoint)，并把下一view的位置记为新的nextPoint，并把view的tag值-1,依次处理
    __block CGPoint  wbtPoint = btPoint;
    [UIView animateWithDuration:0.3 animations:^{
        for (NSInteger i = btIndex+1; i<totalNumber; i++) {
            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
            nextPoint = nextBt.center;
            nextBt.center = wbtPoint;
            wbtPoint = nextPoint;
            
            nextBt.tag --;
            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
            
        }
        
    } completion:^(BOOL finished) {
        totalNumber--;
    }];
    
    
    
}

/**
 * 拖拽手势
 * 无论怎样拖拽移动 页面上view的tag值是一直按顺序排列的，这个作为排序标准
 */
/*
-(void)pan:(UIPanGestureRecognizer*)recognizer{
    //
    UIButton *recognizerView = (UIButton *)recognizer.view;
 
    // 获取移动偏移量
    CGPoint recognizerPoint = [recognizer translationInView:self.view];
    NSLog(@"_____%@",NSStringFromCGPoint(recognizerPoint));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        // 开始的时候改变拖动view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            recognizerView.alpha = 0.7;
        }];
        
        // 把拖动view放到最上层
        [self.view bringSubviewToFront:recognizerView];
        
        // valuePoint保存最新的移动位置
        valuePoint = recognizerView.center;
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        // 更新pan.view的center
        CGFloat x = recognizerView.center.x + recognizerPoint.x;
        CGFloat y = recognizerView.center.y + recognizerPoint.y;
        recognizerView.center = CGPointMake(x, y);
        
        // 因为拖动会持续执行 所以每次结束都要清空
        [recognizer setTranslation:CGPointZero inView:self.view];
        
        for (UIButton * bt in self.view.subviews) {
            
            // 判断是否移动到另一个view区域
            // CGRectContainsPoint(rect,point) 判断某个点是否被某个frame包含
            if (CGRectContainsPoint(bt.frame, recognizerView.center)&&bt!=recognizerView)
            {
                
                // 开始位置
                NSInteger fromIndex = recognizerView.tag - KBase_tag;
                
                // 需要移动到的位置
                NSInteger toIndex = bt.tag - KBase_tag;
                NSLog(@"开始位置=%ld  结束位置=%ld",fromIndex,toIndex);
                
                // 往后移动
                if ((toIndex-fromIndex)>0) {
                    
                    // 从开始位置移动到结束位置
                    // 把移动view的下一个view移动到记录的view的位置(valuePoint)，并把下一view的位置记为新的nextPoint，并把view的tag值-1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex+1; i<=toIndex; i++) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            
                            nextBt.tag--;
                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                            
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                        
                    }];
                    
                }
                // 往前移动
                else
                {
                    // 从开始位置移动到结束位置
                    // 把移动view的上一个view移动到记录的view的位置(valuePoint)，并把上一view的位置记为新的nextPoint，并把view的tag值+1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex-1; i>=toIndex; i--) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            
                            nextBt.tag++;
                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                        
                    }];
                    
                }
                
                
                
            }
            
        }
        
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        
        // 结束时候恢复view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            recognizerView.alpha = 1;
            
            recognizerView.center = valuePoint;
        }];
    }
    
    
}
*/

/**
 *  长按手势
 */
-(void)longPress:(UIGestureRecognizer*)recognizer{
    //
    UIButton *recognizerView = (UIButton *)recognizer.view;
    
    // 禁用其他按钮的拖拽手势
    for (UIButton * bt in self.view.subviews) {
        if (bt!=recognizerView) {
            bt.userInteractionEnabled = NO;
        }
    }
    
    // 长按视图在父视图中的位置（触摸点的位置）
    CGPoint recognizerPoint = [recognizer locationInView:self.view];
    NSLog(@"_____%@",NSStringFromCGPoint(recognizerPoint));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        // 开始的时候改变拖动view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            recognizerView.alpha = 0.7;
        }];
        
        // 把拖动view放到最上层
        [self.view bringSubviewToFront:recognizerView];
        
        // valuePoint保存最新的移动位置
        valuePoint = recognizerView.center;
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        // 更新pan.view的center
        recognizerView.center = recognizerPoint;
        
        /**
         * 可以创建一个继承UIButton的类(MyButton)，这样便于扩展，增加一些属性来绑定数据
         * 如果在self.view上加其他控件拖拽会奔溃，可以在下面方法里面加判断MyButton，也可以把所有按钮放到一个全局变量的UIView上来替换self.view
         
         */
        for (UIButton * bt in self.view.subviews) {
           
            // 判断是否移动到另一个view区域
            // CGRectContainsPoint(rect,point) 判断某个点是否被某个frame包含
            if (CGRectContainsPoint(bt.frame, recognizerView.center)&&bt!=recognizerView)
            {
                NSLog(@"bt_______%@",bt);
                // 开始位置
                NSInteger fromIndex = recognizerView.tag - KBase_tag;
                
                // 需要移动到的位置
                NSInteger toIndex = bt.tag - KBase_tag;
                NSLog(@"开始位置=%ld  结束位置=%ld",fromIndex,toIndex);
                
                // 往后移动
                if ((toIndex-fromIndex)>0) {
                    
                    // 从开始位置移动到结束位置
                    // 把移动view的下一个view移动到记录的view的位置(valuePoint)，并把下一view的位置记为新的nextPoint，并把view的tag值-1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex+1; i<=toIndex; i++) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            
                            nextBt.tag--;
                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                            
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                        
                    }];
                    
                }
                // 往前移动
                else
                {
                    // 从开始位置移动到结束位置
                    // 把移动view的上一个view移动到记录的view的位置(valuePoint)，并把上一view的位置记为新的nextPoint，并把view的tag值+1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex-1; i>=toIndex; i--) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            
                            nextBt.tag++;
                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                        
                    }];
                    
                }
                
                
                
            }
            
        }
        
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        // 恢复其他按钮的拖拽手势
        for (UIButton * bt in self.view.subviews) {
            if (bt!=recognizerView) {
                bt.userInteractionEnabled = YES;
            }
        }

        // 结束时候恢复view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            recognizerView.alpha = 1;
            
            recognizerView.center = valuePoint;
        }];
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
