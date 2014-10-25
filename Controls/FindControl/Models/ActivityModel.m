//
//  ActivityModel.m
//  OneTheBike
//
//  Created by soulnear on 14-10-23.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel

-(id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            [self setValuesForKeysWithDictionary:dic];
        }
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"forUndefinedKey %@",key);
}




@end
