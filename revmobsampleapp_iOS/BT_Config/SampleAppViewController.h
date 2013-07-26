///////////////////////////////////////////////////
// RevMob

#import <UIKit/UIKit.h>
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>

#import <CoreLocation/CoreLocation.h>

@interface SampleAppViewController : UIViewController <RevMobAdsDelegate, CLLocationManagerDelegate> {
    UIScrollView *scroll;
}

@property (nonatomic, strong)RevMobFullscreen *fullscreen;
@property (nonatomic, strong)RevMobBannerView *banner;
@property (nonatomic, strong)RevMobBanner *bannerWindow;
@property (nonatomic, strong)RevMobAdLink *link;

@end

///////////////////////////////////////////////////