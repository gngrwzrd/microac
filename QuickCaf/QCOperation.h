
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
	BOOL _appendChecked;
		
	NSOperationQueue * _queue;
	NSTask * _task;
	NSString * _execPath;
	
	NSString * _file;
	NSMutableDictionary * _conversionInfo;
	NSString * _conversionType;
	NSString * _conversionExtension;
	NSString * _conversionDataFormat;
	NSString * _conversionDataFormatLabel;
	NSString * _conversionOutputDirectory;
	NSString * _conversionSampleRate;
	NSInteger _conversionChannels;
	NSString * _conversionBitRate;
}

@property (nonatomic,assign) NSOperationQueue * queue;
@property (nonatomic,assign) NSInteger conversionChannels;
@property (nonatomic,copy) NSString * file;
@property (nonatomic,copy) NSString * conversionType;
@property (nonatomic,copy) NSString * conversionExtension;
@property (nonatomic,copy) NSString * conversionDataFormat;
@property (nonatomic,copy) NSString * conversionDataFormatLabel;
@property (nonatomic,copy) NSString * conversionOutputDirectory;
@property (nonatomic,copy) NSString * conversionSampleRate;
@property (nonatomic,copy) NSString * conversionBitRate;
@property (nonatomic,retain) NSMutableDictionary * conversionInfo;
@property (nonatomic,assign) BOOL isInQueue;
@property (nonatomic,assign) BOOL appendChecked;

- (void) invalidate;
- (NSString *) shortFormatLabel;
- (NSString *) outputLabel;

@end
