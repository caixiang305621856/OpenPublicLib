//
//  VPCheckViewController.m
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2018/2/8.
//  Copyright © 2018年 vernepung. All rights reserved.
//

#import "VPCheckViewController.h"
#import "BaseCell.h"
#import "Helper.h"
@interface VPCheckViewController ()<VPTableViewViewControllerDelegate>
@property (strong, nonatomic) NSArray<NSString *> *titles;
@end

@implementation VPCheckViewController
- (void)setStaticDatas {
    self.title = @"检测结果";
    self.titles = @[@"可复用",@"不可复用",@"不希望被检测",@"非BaseCell",@"非Cell"];
}

- (void)setupViews {
    self.vp_tableView.dataSource = self;
    self.vp_tableView.delegate = self;
    self.vp_tableView.rowHeight = 49.f;
    [self.vp_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"forCellReuseIdentifier"];
}

- (void)requestDatas {
    [self showProgressViewWithTitle:@"监测ing..."];
    NSMutableArray *rightArray = [NSMutableArray array];
    NSMutableArray *errorArray = [NSMutableArray array];
    NSMutableArray *dontArray = [NSMutableArray array];
    NSMutableArray *otherArray = [NSMutableArray array];
    NSMutableArray *tableCellArray = [NSMutableArray array];
    NSEnumerator<NSString *> *enumerator = [[Helper getAllBundleFilesWithExt:@"nib"] objectEnumerator];
    NSString *str;
    NSString *tempClassName;
    while ((str = [enumerator nextObject])) {
        tempClassName = [[str lastPathComponent] stringByDeletingPathExtension];
        Class class = NSClassFromString(tempClassName);
        if (class && [class isSubclassOfClass:[BaseCell class]]) {
            BaseCell *cell = [[[NSBundle mainBundle] loadNibNamed:tempClassName owner:self options:nil] firstObject];
            //NSLog(@"%@ : cellreuseIdentifier-->%@",tempClassName,cell.reuseIdentifier);
            if ([tempClassName isEqualToString:cell.reuseIdentifier]) {
                [rightArray addObject:tempClassName];
            }else if(cell.dontCheck) {
                [dontArray addObject:tempClassName];
            }else{
                [errorArray addObject:tempClassName];
            }
        }else if([class isSubclassOfClass:[UITableViewCell class]]){
            [tableCellArray addObject:tempClassName];
        }else{
            [otherArray addObject:tempClassName];
        }
    }
    [self hideProgressView];
    self.vp_dataSource = [NSMutableArray arrayWithArray:@[rightArray,errorArray,dontArray,tableCellArray,otherArray]];
    [self.vp_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.vp_dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.vp_dataSource[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forCellReuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = self.vp_dataSource[section][row];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, self.view.frame.size.width, 34);
    button.enabled = NO;
    [button setTitle:self.titles[section] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tag = section + 1000;
    button.backgroundColor = [UIColor lightGrayColor];
    return button;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
