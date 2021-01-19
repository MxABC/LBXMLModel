//
//  MainViewController.m
//  testXML
//
//  Created by lbxia on 2021/1/15.
//

#import "MainViewController.h"
#import "ResModel.h"
#import "NSObject+LBXMLModel.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)testXML:(id)sender {
    
//    [self xmlParser];
//    [self xmlWriter];
//
    [self testXml];
}



//xml->model
- (void)xmlParser
{
    //获取xml路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
    //读取xml数据
    NSData *dataXML = [NSData dataWithContentsOfFile:path];
        
    //xml数据 -> Model
//    RootModel *model = [RootModel xml_modelWithJSON:dataXML];
    
    NSLog(@"start");
    RootModel *model = [RootModel jsonModelWithXML:dataXML];

    
    NSLog(@"end:%@",model.root.TagARRAY[0]);
}


//model->xml
- (void)xmlWriter
{
    
    //model初始化
    RootModel *rootModel = [[RootModel alloc]init];
    
    rootModel.root = [[ResModel alloc]init];

    rootModel.root.RESPONSE_CODE = 201;
    rootModel.root.RESPONSE_MSG = @"201错误";
    
    PAGEModel *pm1 =  [[PAGEModel alloc]init];
    pm1.PAGEID = @"pid_1";
    pm1.FILE_NAME = @"fn_1";
    rootModel.root.PAGE = @[pm1];
    
    NODEModel *nm1 = [[NODEModel alloc]init];
    nm1.SUBNODE = @"sn";
    PAGEModel *pm2 =  [[PAGEModel alloc]init];
    pm2.PAGEID = @"pid_2";
    pm2.FILE_NAME = @"fn_2";
    PAGEModel *pm3 =  [[PAGEModel alloc]init];
    pm3.PAGEID = @"pid_3";
    pm3.FILE_NAME = @"fn_3";
    nm1.PAGE = @[pm2,pm3];
    
    
    NODEModel *nm2 = [[NODEModel alloc]init];
    nm2.SUBNODE = @"sn2";
    PAGEModel *pm4 =  [[PAGEModel alloc]init];
    pm4.PAGEID = @"pid_4";
    pm4.FILE_NAME = @"fn_4";
    PAGEModel *pm5 =  [[PAGEModel alloc]init];
    pm5.PAGEID = @"pid_5";
    pm5.FILE_NAME = @"fn_5";
    nm2.PAGE = @[pm4,pm5];
    
    rootModel.root.NODE = @[nm1,nm2];
    
    //model->xml
    NSData *xmlData  = [rootModel jsonModelToXMLData:YES];
    NSString* strXML = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strXML);
}

//xml->model->xml
- (void)testXml
{
    //获取xml路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
    //从xml读取数据
    NSData *dataXML = [NSData dataWithContentsOfFile:path];

    NSString *str = [[NSString alloc]initWithData:dataXML encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    NSLog(@"start");
    RootModel *model = [RootModel jsonModelWithXML:dataXML];
    
//    dataXML = [model xml_modelToXMLData:YES];
    dataXML = [model jsonModelToXMLData:YES];

    
    model = [RootModel jsonModelWithXML:dataXML];
    NSString* strXML = [[NSString alloc]initWithData:dataXML encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strXML);
}



@end
