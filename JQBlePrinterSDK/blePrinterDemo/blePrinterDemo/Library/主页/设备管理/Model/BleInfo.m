//
//  BleInfo.m
//  bleDemo
//
//  Created by wuyaju on 4/1/16.
//  Copyright © 2016 wuyaju. All rights reserved.
//

#import "BleInfo.h"

@implementation BleInfo

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.bleName forKey:@"bleName"];
    [encoder encodeObject:self.bleIdentifier forKey:@"bleIdentifier"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.bleName = [decoder decodeObjectForKey:@"bleName"];
        self.bleIdentifier = [decoder decodeObjectForKey:@"bleIdentifier"];
    }
    return self;
}

@end
