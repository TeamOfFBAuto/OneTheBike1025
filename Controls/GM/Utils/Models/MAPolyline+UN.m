//
//  MAPolyline+UN.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MAPolyline+UN.h"

@implementation MAPolyline (UN)

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"forUndefinedKey %@",key);
}

@end
