//
//  ActivityImageModel.m
//  OneTheBike
//
//  Created by soulnear on 14-10-27.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "ActivityImageModel.h"

@implementation ActivityImageModel
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
