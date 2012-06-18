
#import <Cocoa/Cocoa.h>
#import "QCOperation.h"

@interface QCTableCellView : NSTableCellView {
	Boolean _validSettings;
	NSProgressIndicator * _progress;
	QCOperation * _operation;
	NSTextField  * _customLabel;
	NSTextField * _formatLabel;
	NSTextField * _outputLabel;
	NSImageView * _warning;
	NSImageView * _check;
}

@property (nonatomic,retain) IBOutlet NSProgressIndicator * progress;
@property (nonatomic,retain) IBOutlet NSTextField * customLabel;
@property (nonatomic,retain) IBOutlet NSTextField * formatLabel;
@property (nonatomic,retain) IBOutlet NSTextField * outputLabel;
@property (nonatomic,retain) IBOutlet NSImageView * warning;
@property (nonatomic,retain) IBOutlet NSImageView * check;
@property (nonatomic,retain) QCOperation * operation;

@end
