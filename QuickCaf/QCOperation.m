
#import "QCOperation.h"

NSString * QCOperationStart = @"QCOperationStart";
NSString * QCOperationCancel = @"QCOperationCancel";
NSString * QCOperationComplete = @"QCOperationComplete";
NSString * QCOperationSettingsValid = @"QCOperationSettingsValid";
NSString * QCOperationSettingsInvalid = @"QCOperationSettingsInvalid";
NSString * QCOperationQueueSuspendChange = @"QCOperationQueueSuspendChange";

@implementation QCOperation
@synthesize file = _file;
@synthesize conversionInfo = _conversionInfo;
@synthesize conversionDataFormat = _conversionDataFormat;
@synthesize conversionExtension = _conversionExtension;
@synthesize conversionOutputDirectory = _conversionOutputDirectory;
@synthesize conversionType = _conversionType;
@synthesize conversionSampleRate = _conversionSampleRate;
@synthesize conversionBitRate = _conversionBitRate;
@synthesize conversionChannels = _conversionChannels;
@synthesize conversionDataFormatLabel = _conversionDataFormatLabel;
@synthesize queue = _queue;
@synthesize isInQueue = _isInQueue;
@synthesize appendChecked = _appendChecked;

- (id) init {
	if(!(self = [super init])) return nil;
	_isFinished = FALSE;
	_cancelled = FALSE;
	_isExecuting = FALSE;
	_isInQueue = FALSE;
	_task = [[NSTask alloc] init];
	return self;
}

- (id) copyWithZone:(NSZone *) zone {
	QCOperation * op = [[[self class] allocWithZone:zone] init];
	op->_file = [_file copy];
	op->_conversionInfo = [_conversionInfo retain];
	op->_conversionExtension = [_conversionExtension copy];
	op->_conversionDataFormat = [_conversionDataFormat copy];
	op->_conversionOutputDirectory = [_conversionOutputDirectory copy];
	op->_conversionSampleRate = [_conversionSampleRate copy];
	op->_conversionChannels = _conversionChannels;
	op->_conversionBitRate = [_conversionBitRate copy];
	return op;
}

- (void) main {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	[nfc postNotificationName:QCOperationStart object:self];
	
	_isExecuting = TRUE;
	
	NSString * outFile = NULL;
	NSString * newExtension = _conversionExtension;
	
	//pieces for custom outpur directory
	NSString * fileName = [_file lastPathComponent];
	//NSArray * comps = [fileName componentsSeparatedByString:@"."];
	NSString * fileNameNoExtension = [fileName stringByDeletingPathExtension];
	
	//pieces for same directory output
	//NSArray * comp2 = [_file componentsSeparatedByString:@"."];
	NSString * fileNameNoExtension2 = [_file stringByDeletingPathExtension];
	
	//assemble output dir
	if(_appendChecked) {
		if(_conversionOutputDirectory.length > 0) {
			outFile = [NSString stringWithFormat:@"%@/%@%@%@", _conversionOutputDirectory, fileNameNoExtension, @"_converted", newExtension];
		} else {
			outFile = [NSString stringWithFormat:@"%@%@%@", fileNameNoExtension2, @"_converted", newExtension];
		}
	} else {
		if(_conversionOutputDirectory.length > 0) {
			outFile = [NSString stringWithFormat:@"%@/%@%@", _conversionOutputDirectory, fileNameNoExtension, newExtension];
		} else {
			outFile = [NSString stringWithFormat:@"%@%@", fileNameNoExtension2, newExtension];
		}
	}
	
	outFile = [outFile stringByExpandingTildeInPath];
	
	//setup arguments
	NSMutableArray * arguments = [NSMutableArray array];
	[arguments addObject:@"-f"];
	[arguments addObject:[_conversionInfo objectForKey:@"fileFormat"]];
	[arguments addObject:@"-d"];
	[arguments addObject:[NSString stringWithFormat:@"%@@%@",_conversionDataFormat, _conversionSampleRate]];
	//[arguments addObject:[NSString stringWithFormat:@"%@",_conversionDataFormat]];
	[arguments addObject:@"-b"];
	long bitrate = (long)[_conversionBitRate integerValue] * 1000;
	[arguments addObject:[NSString stringWithFormat:@"%lu",bitrate]];
	if(_conversionChannels > 0) {
		[arguments addObject:@"-c"];
		[arguments addObject:[NSString stringWithFormat:@"%lu",(long)_conversionChannels]];
	}
	[arguments addObject:_file];
	[arguments addObject:outFile];
	[_task setArguments:arguments];
	
	NSLog(@"arguments: %@",arguments);
	
	if(_cancelled) {
		_isFinished = TRUE;
		_isExecuting = FALSE;
		[nfc postNotificationName:QCOperationCancel object:self];
		return;
	}
	
	#if QCOperationFakeIt
		sleep(2);
		_isFinished = TRUE;
		_isExecuting = FALSE;
		_cancelled = FALSE;
		[nfc postNotificationName:QCOperationComplete object:self];
	#else
		[_task setTerminationHandler:^(NSTask * task) {
			_isFinished = TRUE;
			_isExecuting = FALSE;
			_cancelled = FALSE;
			[nfc postNotificationName:QCOperationComplete object:self];
		}];
		[_task setLaunchPath:@"/usr/bin/afconvert"];
		[_task launch];
		[_task waitUntilExit];
	#endif
}

- (BOOL) isConcurrent {
	return TRUE;
}

- (BOOL) isExecuting {
	return _isExecuting;
}

- (BOOL) isCancelled {
	return _cancelled;
}

- (void) setConversionDataFormat:(NSString *) conversionDataFormat {
	if(_conversionDataFormat) [_conversionDataFormat release];
	_conversionDataFormat = [conversionDataFormat copy];
	//NSLog(@"new data format: %@",conversionDataFormat);
}

- (void) invalidate {
	NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
	if(_conversionInfo && _conversionType && _conversionExtension && _conversionDataFormat && _conversionOutputDirectory) {
		if(_conversionSampleRate) {
			[nfc postNotificationName:QCOperationSettingsValid object:self];
			return;
		}
	}
	[nfc postNotificationName:QCOperationSettingsInvalid object:self];
}

- (void) cancel {
	_cancelled = TRUE;
	if(_task.isRunning) [_task interrupt];
}

- (NSString *) shortFormatLabel {
	if(!_conversionDataFormat) return @"No Output Format";
	if(_conversionChannels > 0) {
		return [NSString stringWithFormat:@"Output: %@ (%@) %@@%@ %lich", [_conversionInfo objectForKey:@"fileFormat"], _conversionExtension, _conversionDataFormat, _conversionSampleRate, _conversionChannels];
	} else {
		return [NSString stringWithFormat:@"Output: %@ (%@) %@@%@", [_conversionInfo objectForKey:@"fileFormat"], _conversionExtension, _conversionDataFormat, _conversionSampleRate];
	}
}

- (NSString *) outputLabel {
	//NSLog(@"output: %@",_conversionOutputDirectory);
	if(_conversionOutputDirectory.length > 0) {
		return [NSString stringWithFormat:@"Save To: %@",_conversionOutputDirectory];
	}
	return @"Save To: Destination Not Set!";
	//return @"Save To: Same as source";
}

- (void) dealloc {
	NSLog(@"DEALLOC: QCOperation");
	_queue = NULL;
	
	if(_file) {
		[_file release];
		_file = NULL;
	}
	
	if(_execPath) {
		[_execPath release];
		_execPath = NULL;
	}
	
	if(_conversionInfo) {
		[_conversionInfo release];
		_conversionInfo = NULL;
	}
	
	if(_conversionType) {
		[_conversionType release];
		_conversionType = NULL;
	}
	
	if(_conversionExtension) {
		[_conversionExtension release];
		_conversionExtension = NULL;
	}
	
	if(_conversionDataFormat) {
		[_conversionDataFormat release];
		_conversionDataFormat = NULL;
	}
	
	if(_conversionOutputDirectory) {
		[_conversionOutputDirectory release];
		_conversionOutputDirectory = NULL;
	}
	
	if(_conversionSampleRate) {
		[_conversionSampleRate release];
		_conversionSampleRate = NULL;
	}
	
	if(_task) {
		if(_task.isRunning)[_task interrupt];
		_task = NULL;
	}
	
	[super dealloc];
}

@end
