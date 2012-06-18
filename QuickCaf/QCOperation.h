
#import <Foundation/Foundation.h>

extern NSString * QCOperationStart;
extern NSString * QCOperationCancel;
extern NSString * QCOperationComplete;
extern NSString * QCOperationSettingsValid;
extern NSString * QCOperationSettingsInvalid;
extern NSString * QCOperationQueueSuspendChange;

#define QCOperationFakeIt 0

@interface QCOperation : NSOperation <NSCopying> {
@public
	BOOL _cancelled;
	BOOL _isExecuting;
	BOOL _isFinished;
	BOOL _isInQueue;
		
	NSOperationQueue * _queue;
	NSTask * _task;
	NSString * _execPath;
	
	NSString * _file;
	NSMutableDictionary * _conversionInfo;
	NSString * _conversionType;
	NSString * _conversionExtension;
	NSString * _conversionDataFormat;
	NSString * _conversionOutputDirectory;
	NSString * _conversionSampleRate;
	NSInteger _conversionChannels;
}

@property (nonatomic,assign) NSOperationQueue * queue;
@property (nonatomic,assign) NSInteger conversionChannels;
@property (nonatomic,copy) NSString * file;
@property (nonatomic,copy) NSString * conversionType;
@property (nonatomic,copy) NSString * conversionExtension;
@property (nonatomic,copy) NSString * conversionDataFormat;
@property (nonatomic,copy) NSString * conversionOutputDirectory;
@property (nonatomic,copy) NSString * conversionSampleRate;
@property (nonatomic,retain) NSMutableDictionary * conversionInfo;
@property (nonatomic,assign) BOOL isInQueue;

- (void) invalidate;
- (NSString *) shortFormatLabel;
- (NSString *) outputLabel;

@end
