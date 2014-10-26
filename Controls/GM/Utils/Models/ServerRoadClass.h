//
//  ServerRoadClass.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/27.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "BaseModel.h"

@interface ServerRoadClass : BaseModel

@property(nonatomic,retain)NSString *beginCoordinates;
@property(nonatomic,retain)NSString *beginSite;
@property(nonatomic,retain)NSString *custId;//用户的id
@property(nonatomic,assign)CGFloat distance;
@property(nonatomic,retain)NSString *endCoordinates;

@property(nonatomic,retain)NSString *endSite;
@property(nonatomic,retain)NSString *makeTime;
@property(nonatomic,retain)NSString *rdbkId;//路书id
@property(nonatomic,retain)NSString *roadlines;
@property(nonatomic,retain)NSString *wayCoordinates;

@property(nonatomic,retain)NSString *waySite;

@end
