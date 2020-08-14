//
//  PayPalHerePaymentViewController.h
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayPalHereSDK/PayPalHereSDK.h>

@protocol PayPalHerePaymentViewControllerDelegate <NSObject>

- (void)paymentDidComplete;

@end

@interface PayPalHerePaymentViewController : UIViewController

@property (nonatomic, weak) id <PayPalHerePaymentViewControllerDelegate> delegate;

@property (nonatomic) NSString *tipPrice;
@property (nonatomic) NSString *trackingInfo;

@end
