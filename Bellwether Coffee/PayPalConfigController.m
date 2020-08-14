//
//  PayPalConfigController.m
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/28/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

#import "PayPalConfigController.h"
#import <PayPalHereSDK/PayPalHereSDK.h>

@implementation PayPalConfigController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"INIT");
    }
    return self;
}

- (void)configurePayPal:(NSString *) token {
    [PayPalHereSDK setupWithCompositeTokenString:token thenCompletionHandler:^(PPHInitResultType status, PPHError *error, PPHMerchantInfo *info) {
        NSLog(@"CONFIGURED");
    }];
}

@end
