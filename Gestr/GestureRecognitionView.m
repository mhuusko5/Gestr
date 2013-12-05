#import "GestureRecognitionView.h"

@interface GestureRecognitionView ()

@property NSMutableDictionary *touchPaths;
@property NSMutableDictionary *gestureStrokes;
@property NSMutableArray *orderedStrokeIds;

@property NSTimer *startInputTimer;
@property NSTimer *noInputTimer;
@property NSTimer *detectInputTimer;
@property NSTimer *checkPartialGestureTimer;

@property int mouseStrokeIndex;

@property NSDate *lastMultitouchRedraw;
@property NSNumber *initialMultitouchDeviceId;

@end

@implementation GestureRecognitionView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
    
	_touchPaths = [[NSMutableDictionary alloc] init];
	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];
    
	_lastMultitouchRedraw = [NSDate date];
    
	return self;
}

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType {
	if (!self.recognitionController.appController.gestureSetupController.setupModel.multitouchOption && self.detectingInput) {
		[self resetInputTimers];
        
		NSPoint drawPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        
		if ([mouseType isEqualToString:@"down"]) {
			self.mouseStrokeIndex++;
		}
        
		NSNumber *identity = @(self.mouseStrokeIndex);
        
		if (!(self.gestureStrokes)[identity]) {
			[self.orderedStrokeIds addObject:identity];
			(self.gestureStrokes)[identity] = [[GestureStroke alloc] init];
		}
        
		GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:(drawPoint.x / self.frame.size.width) * GUBoundingBoxSize andY:(drawPoint.y / self.frame.size.height) * GUBoundingBoxSize andStrokeId:[identity intValue]];
        
		[(self.gestureStrokes)[identity] addPoint:detectorPoint];
        
		if ([mouseType isEqualToString:@"down"]) {
			NSBezierPath *tempPath = [NSBezierPath bezierPath];
			[tempPath setLineWidth:self.frame.size.width / 95];
			[tempPath setLineCapStyle:NSRoundLineCapStyle];
			[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
			[tempPath moveToPoint:drawPoint];
            
			(self.touchPaths)[identity] = tempPath;
		}
		else if ([mouseType isEqualToString:@"drag"]) {
			NSBezierPath *tempPath = (self.touchPaths)[identity];
			[tempPath lineToPoint:drawPoint];
		}
		else if ([mouseType isEqualToString:@"up"]) {
			if (self.mouseStrokeIndex < 3) {
				if (!self.detectInputTimer) {
					self.detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)self.recognitionController.appController.gestureSetupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
				}
			}
			else {
				[self finishDetectingGesture];
				return;
			}
            
			NSBezierPath *tempPath = (self.touchPaths)[identity];
			[tempPath lineToPoint:drawPoint];
		}
        
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"down"];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"drag"];
}

- (void)mouseUp:(NSEvent *)theEvent {
	[self dealWithMouseEvent:theEvent ofType:@"up"];
}

- (void)dealWithMultitouchEvent:(MultitouchEvent *)event {
	if (self.recognitionController.appController.gestureSetupController.setupModel.multitouchOption && self.detectingInput) {
		if (!self.initialMultitouchDeviceId) {
			self.initialMultitouchDeviceId = event.deviceIdentifier;
		}
        
		if ([event.deviceIdentifier isEqualToNumber:self.initialMultitouchDeviceId]) {
			[self resetInputTimers];
            
			if (!self.detectInputTimer && event.touches.count == 0) {
				self.detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)self.recognitionController.appController.gestureSetupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
			}
			else {
				int shouldDrawLimit = self.recognitionController.appController.gestureSetupController.setupModel.fullscreenOption ? 32 : 16;
				BOOL shouldDraw = ([self.lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > shouldDrawLimit);
                
				for (MultitouchTouch *touch in event.touches) {
					float combinedTouchVelocity = fabs(touch.velX) + fabs(touch.velY);
					if (touch.state == 4 && combinedTouchVelocity > 0.06) {
						NSPoint drawPoint = NSMakePoint(touch.x, touch.y);
                        
						NSNumber *identity = touch.identifier;
                        
						if (!(self.gestureStrokes)[identity]) {
							if (self.orderedStrokeIds.count < 3) {
								[self.orderedStrokeIds addObject:identity];
								(self.gestureStrokes)[identity] = [[GestureStroke alloc] init];
							}
							else {
								continue;
							}
						}
                        
						GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:drawPoint.x * GUBoundingBoxSize andY:drawPoint.y * GUBoundingBoxSize andStrokeId:[identity intValue]];
                        
						[(self.gestureStrokes)[identity] addPoint:detectorPoint];
                        
                        drawPoint.x *= self.frame.size.width;
                        drawPoint.y *= self.frame.size.height;
                        
                        NSBezierPath *tempPath;
                        if ((tempPath = (self.touchPaths)[identity])) {
                            [tempPath lineToPoint:drawPoint];
                        }
                        else {
                            tempPath = [NSBezierPath bezierPath];
                            [tempPath setLineWidth:self.frame.size.width / 95];
                            [tempPath setLineCapStyle:NSRoundLineCapStyle];
                            [tempPath setLineJoinStyle:NSRoundLineJoinStyle];
                            [tempPath moveToPoint:drawPoint];
                            
                            (self.touchPaths)[identity] = tempPath;
                        }
                    }
				}
                
				if (shouldDraw) {
					[self setNeedsDisplay:YES];
					self.lastMultitouchRedraw = [NSDate date];
				}
			}
		}
	}
}

- (void)startMultitouchInput {
    [[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(dealWithMultitouchEvent:) andThread:nil];
}

- (void)startDetectingGesture {
	[self resetAll];
    
    self.mouseStrokeIndex = 0;
    
    self.initialMultitouchDeviceId = nil;
    
    self.checkPartialGestureTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(checkPartialGesture) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.checkPartialGestureTimer forMode:NSEventTrackingRunLoopMode];
    
    self.noInputTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];
    
    [self becomeFirstResponder];
    
    if (self.recognitionController.appController.gestureSetupController.setupModel.multitouchOption) {
        [NSApp activateIgnoringOtherApps:YES];
        CGAssociateMouseAndMouseCursorPosition(NO);
        
        self.startInputTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startMultitouchInput) userInfo:nil repeats:NO];
    }
    
    self.detectingInput = YES;
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGestureIgnore {
    [self finishDetectingGesture:YES];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	self.detectingInput = NO;
    
    if (self.recognitionController.appController.gestureSetupController.setupModel.multitouchOption) {
        [[MultitouchManager sharedMultitouchManager] removeMultitouchListenersWithTarget:self andCallback:@selector(dealWithMultitouchEvent:)];
        CGAssociateMouseAndMouseCursorPosition(YES);
    }
    
    NSMutableArray *orderedStrokes = [NSMutableArray array];
    if (!ignore) {
        for (int i = 0; i < self.orderedStrokeIds.count; i++) {
            [orderedStrokes addObject:(self.gestureStrokes)[(self.orderedStrokeIds)[i]]];
        }
    }
    
    [self resetAll];
    
    [self.recognitionController recognizeGestureWithStrokes:orderedStrokes];
}

- (void)checkPartialGesture {
	if (self.orderedStrokeIds.count > 0) {
		[self performSelectorInBackground:@selector(checkPartialGestureOnNewThread) withObject:nil];
	}
}

- (void)checkPartialGestureOnNewThread {
	NSMutableArray *partialOrderedStrokeIds = [self.orderedStrokeIds copy];
	NSMutableDictionary *partialGestureStrokes = [self.gestureStrokes copy];
    
	NSMutableArray *partialOrderedStrokes = [NSMutableArray array];
	for (int i = 0; i < partialOrderedStrokeIds.count; i++) {
		[partialOrderedStrokes addObject:partialGestureStrokes[partialOrderedStrokeIds[i]]];
	}
    
	[self.recognitionController checkPartialGestureWithStrokes:partialOrderedStrokes];
}

- (void)resetInputTimers {
    if (self.startInputTimer) {
		[self.startInputTimer invalidate];
		self.startInputTimer = nil;
	}
    
    if (self.noInputTimer) {
		[self.noInputTimer invalidate];
		self.noInputTimer = nil;
	}
    
	if (self.detectInputTimer) {
		[self.detectInputTimer invalidate];
		self.detectInputTimer = nil;
	}
}

- (void)resetAll {
    [self resetInputTimers];
    
    if (self.checkPartialGestureTimer) {
		[self.checkPartialGestureTimer invalidate];
		self.checkPartialGestureTimer = nil;
	}
    
    self.gestureStrokes = [NSMutableDictionary dictionary];
	self.orderedStrokeIds = [NSMutableArray array];
	[self.touchPaths removeAllObjects];
    
    self.lastMultitouchRedraw = [NSDate date];
    
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (self.detectingInput) {
		for (NSBezierPath *path in[self.touchPaths allValues]) {
			[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.36] setStroke];
			path.lineWidth *= 1.5;
			[path stroke];
            
			[myGreenColor setStroke];
			path.lineWidth /= 1.5;
			[path stroke];
		}
	}
}

@end
