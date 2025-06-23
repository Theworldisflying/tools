//
//  MethodTool.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/2/20.
//

#import <Foundation/Foundation.h>

//AES
// key跟后台协商一个即可，保持一致
static NSString *const PSW_AES_KEY = @"17BzFhcM+QOhKDysbkD5ZHkhXMtY3g2pcUYMZnuNniU=";
// 这里的偏移量也需要跟后台一致，一般跟key一样就行
static NSString *const AES_IV_PARAMETER = @"FRr+9gkro4wpJInLtKL+lg==";

@interface MethodTool : NSObject
+ (NSString*)trimSpace:(NSString*)content;

+ (BOOL)checkLoginWithVc:(UIViewController *)Vc;

+ (UIView *)addLineView:(CGRect)frame;

+ (NSString *)getUUIDByKeyChain;

+ (NSString *)errorTextWithError:(NSError *)error;

+ (NSString *)currentZone;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSString *)InterceptString:(NSString *)string;

+ (NSString *)currentCountryName;

+ (NSString *)optimizeAddress:(NSString *)text;

+ (NSString *)convertToJsonData:(NSDictionary *)dict;

+ (BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;

+ (NSString *)getTodayStartTime;

+ (NSString *)getTodayEndTime;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (BOOL)isNineKeyBoard:(NSString *)string;

+ (BOOL)hasEmoji:(NSString*)string;

+ (BOOL)stringContainsEmoji:(NSString *)string;

+ (void)presentVc:(UIViewController *)vc
            Title:(NSString *)title
          message:(NSString *)message
cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
    actionHandler:(void (^)(NSInteger buttonIndex))actionHandler;

+ (void)showAlertWithVc:(UIViewController *)vc
                  Title:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString *)cancelButtonTitle
      otherButtonTitles:(NSArray *)otherButtonTitles
          actionHandler:(void (^)(NSInteger buttonIndex))actionHandler;

//+ (void)showAlertWithTitle:(NSString *)title
//                   message:(NSString *)message
//         cancelButtonTitle:(NSString *)cancelButtonTitle
//         otherButtonTitles:(NSArray *)otherButtonTitles
//             actionHandler:(void (^)(NSInteger buttonIndex))actionHandler;

+ (NSDictionary *)deviceWANIPAdress;

+ (NSString *)getSandBoxFilePath:(NSString *)fileName;

+ (BOOL)isnNotSet:(NSString *)string;

+ (BOOL)removeDataWithFilePath:(NSString *)fileName;

+ (BOOL) isBlankString:(NSString *)string;

+ (CLLocationCoordinate2D)locationForItemWithLat:(NSString *)latitudeStr andLon:(NSString *)longtitudeStr;

+ (UIImage *)initWithColor:(UIColor*)color rect:(CGRect)rect;

+ (NSString *)encryptUseDES2:(NSString *)plainText key:(NSString *)key;

+ (NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;

+ (NSString *)wifiMac;

+ (NSString *)deviceIPAdress;

+ (BOOL) isValidEmail:(NSString *)email;

+ (BOOL)coordinateOfChina:(CLLocationCoordinate2D)location;



/**
 *  将WGS-84转为GCJ-02(火星坐标):
 */
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
/**
 *  将GCJ-02(火星坐标)转为WGS-84:
 */
+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D)p;

+ (NSMutableAttributedString *)create_introduce:(NSString *)title detail:(NSString *)detail;


+ (BOOL)isNumber:(NSString *)strValue;

+ (BOOL)getUserLocationAuth;

+ (UIImage *)imageWithOriginal:(NSString *)imageName;

+ (NSString *)iphoneType;

+ (NSString *)errorCodePrompt:(NSInteger)domain;

+ (NSString *)monthToshorthandMonth:(NSString *)month;

+ (NSString *)monthFullTextMonth:(NSString *)month;

+ (NSString *)monthIntegertMonth:(NSString *)month;

+ (NSString *)placeholderImagePort:(NSInteger )port gender:(NSString *)gender;

+ (NSString *)calculationDataWithBytes:(int64_t)tytes;

+ (BOOL)isWithSerialNumberString:(NSString *)string;

+ (NSString *)getLanguageText;

+ (NSMutableArray *)getAMERICAsoftware;

+ (NSMutableArray *)getEUROPEsoftware;

+ (NSMutableArray *)getASIAsoftware;

+ (NSString *)nsdataChangeNsstring:(NSData *)data;

/// 是否Pad
+ (BOOL)kb_isPad;

/// 是否竖屏
+ (BOOL)kb_isPortrait;
/// 状态栏高度 iPhoneX：34 其他：20
+ (CGFloat)kb_statusBarHeight;

/// 导航栏高度 iPad：50 iPhone：44
+ (CGFloat)kb_navBarHeight;

/// 状态栏高度+导航栏高度
+ (CGFloat)kb_statusNavHeight;

/// 顶部安全高度 iPhoneX：44 其他：20
+ (CGFloat)kb_topSafeHeight;

/// 底部安全高度 iPhoneX：34 其他：0
+ (CGFloat)kb_bottomSafeHeight;

/// 安全区域
+ (UIEdgeInsets)kb_safeAreaInset;
@end
