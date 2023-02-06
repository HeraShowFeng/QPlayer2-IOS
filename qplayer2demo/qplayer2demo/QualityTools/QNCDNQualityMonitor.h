//
//  QNCDNQualityMonitor.h
//  qplayer2demo
//
//  Created by 冯文秀 on 2023/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @abstract 质量等级
 */
typedef NS_ENUM(NSUInteger, QNCDNQualityGrade) {
    /*!
     * @abstract 好
     */
    QNCDNQualityGradeGood = 0,
    
    /*!
     * @abstract 中
     */
    QNCDNQualityGradeFair,
    
    /*!
     * @abstract 差
     */
    QNCDNQualityGradePoor,
};

@class QNCDNQualityMonitor;

@protocol QNCDNQualityDelegate <NSObject>

@optional

/*!
 * @abstract 质量监控信息回调
 */
- (void)qualityMonitor:(QNCDNQualityMonitor *)qualityMonitor url:(NSString *)url rtt:(int)rtt;

@end

@interface QNCDNQualityMonitor : NSObject
// 设置监控周期，默认 3s
@property (nonatomic, assign) NSTimeInterval interval;
// 监控回调代理
@property (nonatomic, weak) id<QNCDNQualityDelegate> delegate;

// 添加监控
- (void)addObserver:(NSString *)url;
// 移除监控
- (void)removeObserver:(NSString *)url;

// 开始监控
- (void)start;
// 结束监控
- (void)stop;
@end

NS_ASSUME_NONNULL_END
