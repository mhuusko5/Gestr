#import "GestureSetupView.h"

@interface GestureSetupView ()

@property NSMutableDictionary *touchPaths;
@property NSMutableDictionary *gestureStrokes;
@property NSMutableArray *orderedStrokeIds;

@property NSTimer *startInputTimer;
@property NSTimer *noInputTimer;
@property NSTimer *detectInputTimer;

@property int mouseStrokeIndex;

@property BOOL showingStoredGesture;

@property NSDate *lastMultitouchRedraw;
@property NSNumber *initialMultitouchDeviceId;

@end

@implementation GestureSetupView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
    
	_touchPaths = [[NSMutableDictionary alloc] init];
	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];
    
	_lastMultitouchRedraw = [NSDate date];
    
	return self;
}

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType {
	if (!self.setupController.setupModel.multitouchOption && self.detectingInput) {
		[self.setupController showDrawNotification:NO];
        
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
			[tempPath setLineWidth:6.0];
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
					self.detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)self.setupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
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
	if (self.setupController.setupModel.multitouchOption && self.detectingInput) {
		[self.setupController showDrawNotification:NO];
        
		if (!self.initialMultitouchDeviceId) {
			self.initialMultitouchDeviceId = event.deviceIdentifier;
		}
        
		if ([event.deviceIdentifier isEqualToNumber:self.initialMultitouchDeviceId]) {
			[self resetInputTimers];
            
			if (!self.detectInputTimer && event.touches.count == 0) {
				self.detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)self.setupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
			}
			else {
				BOOL shouldDraw = ([self.lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > 16);
                
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
                            [tempPath setLineWidth:6.0];
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
    
    [self.setupController showDrawNotification:YES];
    
    self.noInputTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];
    
    [self becomeFirstResponder];
    
    if (self.setupController.setupModel.multitouchOption) {
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
    
	if (self.setupController.setupModel.multitouchOption) {
        [[MultitouchManager sharedMultitouchManager] removeMultitouchListenersWithTarget:self andCallback:@selector(dealWithMultitouchEvent:)];
        CGAssociateMouseAndMouseCursorPosition(YES);
    }
    
    if (!ignore) {
        NSMutableArray *orderedStrokes = [NSMutableArray array];
        for (int i = 0; i < self.orderedStrokeIds.count; i++) {
            [orderedStrokes addObject:(self.gestureStrokes)[(self.orderedStrokeIds)[i]]];
        }
        
        [self.setupController saveGestureWithStrokes:orderedStrokes];
    }
    
    [self resetAll];
}

- (void)showGesture:(Gesture *)gesture {
	self.showingStoredGesture = YES;
    
	[self resetAll];
	if (gesture) {
		int pointIndex = 0;
		while (YES) {
			if ([[NSThread currentThread] isCancelled] || self.detectingInput) {
				[NSThread exit];
			}
            
			if (pointIndex % 2 == 0) {
				[self setNeedsDisplay:YES];
			}
            
			pointIndex++;
            
			BOOL contin;
			for (GestureStroke *stroke in gesture.strokes) {
				if (pointIndex < stroke.pointCount) {
					contin = YES;
					break;
				}
			}
            
			if (!contin) {
				break;
			}
            
			for (int strokeIndex = 0; strokeIndex < gesture.strokes.count; strokeIndex++) {
				GestureStroke *cStroke = (gesture.strokes)[strokeIndex];
				if (pointIndex < cStroke.pointCount) {
					GesturePoint *cPoint = (cStroke.points)[pointIndex];
                    
					NSPoint drawPoint = NSMakePoint([cPoint getX] / GUBoundingBoxSize * self.frame.size.width, [cPoint getY] / GUBoundingBoxSize * self.frame.size.height);
                    
					NSString *ident = [NSString stringWithFormat:@"%i", strokeIndex];
                    
					if (pointIndex == 1) {
						NSBezierPath *tempPath = [NSBezierPath bezierPath];
						[tempPath setLineWidth:6.0];
						[tempPath setLineCapStyle:NSRoundLineCapStyle];
						[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
						[tempPath moveToPoint:drawPoint];
						(self.touchPaths)[ident] = tempPath;
					}
					else if (pointIndex > 1 && pointIndex < [cStroke pointCount]) {
						NSBezierPath *tempPath = (self.touchPaths)[ident];
						[tempPath lineToPoint:drawPoint];
					}
					else if (pointIndex == [cStroke pointCount]) {
						NSBezierPath *tempPath = (self.touchPaths)[ident];
						[tempPath lineToPoint:drawPoint];
						[self.touchPaths removeObjectForKey:ident];
					}
				}
			}
            
			[NSThread sleepForTimeInterval:0.006];
		}
	}
    
	self.showingStoredGesture = NO;
}

- (BOOL)resignFirstResponder {
	[self finishDetectingGesture:YES];
    
	return YES;
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
    [self.setupController showDrawNotification:NO];
    
    [self resetInputTimers];
    
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
	if (self.detectingInput || self.showingStoredGesture) {
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
