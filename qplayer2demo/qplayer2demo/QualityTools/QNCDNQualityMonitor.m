//
//  QNCDNQualityMonitor.m
//  qplayer2demo
//
//  Created by 冯文秀 on 2023/2/3.
//

#import "QNCDNQualityMonitor.h"

#define QN_MONITOR_INTERVAL 3

@interface QNCDNQualityMonitor()
@property (nonatomic, strong) NSMutableArray *urlsArray;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSTimer *detectTimer;
@end

@implementation QNCDNQualityMonitor

#pragma mark - public

- (instancetype)init {
    if (self = [super init]) {
        _interval = QN_MONITOR_INTERVAL;
        _urlsArray = [NSMutableArray array];
        _isRunning = NO;
    }
    return self;
}

- (void)addObserver:(NSString *)url {
    [_urlsArray addObject:url];
}

- (void)removeObserver:(NSString *)url {
    [_urlsArray removeObject:url];
}

- (void)start {
    if (_isRunning) {
        return;
    }
    [self startDetectTimer];
}

- (void)stop {
    if (!_isRunning) {
        return;
    }
    [self stopStatisticTimer];
}

#pragma mark - private

- (void)startDetectTimer {
    if (self.detectTimer && !_isRunning) {
        return;
    }
    _isRunning = YES;
    
    self.detectTimer = [NSTimer timerWithTimeInterval:_interval
                                               target:self
                                             selector:@selector(detectQuality)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.detectTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopStatisticTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(detectQuality) object:nil];
    [self.detectTimer invalidate];
    self.detectTimer = nil;
    _isRunning = NO;
}

- (void)detectQuality {
    for (NSString *url in _urlsArray) {
        NSString *key = [NSURL URLWithString:url].host;
        NSString *requestURL = [NSString stringWithFormat:@"http://%@", key];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPMethod = @"GET";
        
        long startTime = [self currentTimestamp];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (response != 0) {
                long requestTime = [self currentTimestamp] - startTime;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(qualityMonitor:url:rtt:)]) {
                        // HTTP 1.1 开始默认开启 keep-alive 即复用了 TCP 连接，无需除以 2
                        [self.delegate qualityMonitor:self url:url rtt:(int)requestTime];
                    }
                });
            }
        }];
        [task resume];
    }
}

- (long long)currentTimestamp {
    return (long long)(1000 * [[NSDate date] timeIntervalSince1970]);
}

@end
