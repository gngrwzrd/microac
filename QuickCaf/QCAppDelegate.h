
#import <Cocoa/Cocoa.h>
#import "QCDragDropView.h"

@interface QCAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSToolbarDelegate, NSWindowDelegate> {
	NSWindow * _window;
	
	NSSound * _glass;
	NSTimer * _reloadLater;
	NSArray * _files;
	NSArray * _extensions;
	NSMutableArray * _targetFormats;
	NSMutableDictionary * _formats;
	NSOperationQueue * _workQueue;
	NSRecursiveLock * _workOperationsLock;
	NSMutableArray * _workOperations;
	Boolean _settingsAreValid;
	NSArray * _selectedOperations;
	NSInteger _noSelectionLastTypeIndex;
	NSInteger _noSelectionLastContainerIndex;
	NSInteger _noSelectionLastDataFormatIndex;
	
	//queue area
	NSScrollView * _tableScrollView;
	NSTableView * _tableView;
//	NSProgressIndicator * _totalProgress;
//	NSTextField * _totalProgressLabel;
	NSButton * _removeItemsFromQueue;
	NSTextField * _concurrencyLabel;
	NSStepper * _concurrencyStepper;
	
	//quick drop area
	NSOperationQueue * _quickQueue;
	QCDragDropView * _quickDropView;
	NSView * _quickDropViewContainer;
	NSTextField * _quickDropLabel;
	NSProgressIndicator * _quickDropProgress;
	NSImageView * _quickDropBGImage;
	
	//output area
	NSMenuItem * _selectedType;
	NSMenuItem * _selectedContainer;
	NSMenuItem * _selectedDataFormat;
	NSPopUpButton * _targetFormat;
	NSPopUpButton * _containerFormat;
	NSPopUpButton * _dataFormat;
	NSComboBox * _sampleRate;
	NSButton * _outputSameDir;
	NSTextField * _outputDir;
	NSButton * _outputChoose;
	NSButton * _revealOutputDir;
	
	//channel
	NSTextField * _channelsLabel;
	NSTextField * _channelsCountLabel;
	NSStepper   * _channelsStepper;
	
	//options
	NSButton * _audioAlerts;
}

@property (assign) IBOutlet NSWindow * window;
//@property (assign) IBOutlet NSProgressIndicator * totalProgress;
@property (assign) IBOutlet NSScrollView * tableScrollView;
@property (assign) IBOutlet NSTableView * tableView;
@property (assign) IBOutlet NSPopUpButton * containerFormat;
@property (assign) IBOutlet NSPopUpButton * dataFormat;
@property (assign) IBOutlet NSComboBox * sampleRate;
@property (assign) IBOutlet NSButton * outputSameDir;
@property (assign) IBOutlet NSButton * outputChooseDir;
@property (assign) IBOutlet NSButton * revealOutputDir;
@property (assign) IBOutlet NSTextField * outputDir;
//@property (assign) IBOutlet NSTextField * totalProgressLabel;
@property (assign) IBOutlet NSButton * removeItemsFromQueue;
@property (assign) IBOutlet NSTextField * channelsLabel;
@property (assign) IBOutlet NSTextField * channelsCountLabel;
@property (assign) IBOutlet NSStepper * channelsStepper;
@property (assign) IBOutlet NSPopUpButton * targetFormat;
@property (assign) IBOutlet NSToolbarItem * convertButton;
@property (assign) IBOutlet NSButton * audioAlerts;
@property (assign) IBOutlet NSTextField * concurrencyLabel;
@property (assign) IBOutlet NSStepper * concurrencyStepper;
@property (assign) IBOutlet NSTextField * quickDropLabel;
@property (nonatomic,retain) IBOutlet NSProgressIndicator * quickDropProgress;
@property (assign) IBOutlet QCDragDropView * quickDropView;
@property (nonatomic,retain) IBOutlet NSView * quickDropViewContainer;
@property (nonatomic,retain) IBOutlet NSImageView * quickDropBGImage;

- (void) invalidateWorkQueue;

@end
