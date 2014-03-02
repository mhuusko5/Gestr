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

	_touchPaths = [NSMutableDictionary dictionary];
	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];

	_lastMultitouchRedraw = [NSDate date];

	return self;
}

- (void)dealWithMouseEvent:(NSEvent *)event ofType:(NSString *)mouseType {
	if (!_setupController.setupModel.multitouchOption && _detectingInput) {
		[_setupController showDrawNotification:NO];

		[self resetInputTimers];

		NSPoint drawPoint = [self convertPoint:[event locationInWindow] fromView:nil];

		if ([mouseType isEqualToString:@"down"]) {
			_mouseStrokeIndex++;
		}

		NSNumber *identity = @(_mouseStrokeIndex);

		if (!_gestureStrokes[identity]) {
			[_orderedStrokeIds addObject:identity];
			_gestureStrokes[identity] = [[GestureStroke alloc] init];
		}

		GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:(drawPoint.x / self.frame.size.width) * GUBoundingBoxSize andY:(drawPoint.y / self.frame.size.height) * GUBoundingBoxSize andStrokeId:[identity intValue]];

		[_gestureStrokes[identity] addPoint:detectorPoint];

		if ([mouseType isEqualToString:@"down"]) {
			NSBezierPath *tempPath = [NSBezierPath bezierPath];
			[tempPath setLineWidth:6.0];
			[tempPath setLineCapStyle:NSRoundLineCapStyle];
			[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
			[tempPath moveToPoint:drawPoint];

			_touchPaths[identity] = tempPath;
		}
		else if ([mouseType isEqualToString:@"drag"]) {
			NSBezierPath *tempPath = _touchPaths[identity];
			[tempPath lineToPoint:drawPoint];
		}
		else if ([mouseType isEqualToString:@"up"]) {
			if (_mouseStrokeIndex < 3) {
				if (!_detectInputTimer) {
					_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_setupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
				}
			}
			else {
				[self finishDetectingGesture];
				return;
			}

			NSBezierPath *tempPath = _touchPaths[identity];
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
	if (_setupController.setupModel.multitouchOption && _detectingInput) {
		[_setupController showDrawNotification:NO];

		if (!_initialMultitouchDeviceId) {
			_initialMultitouchDeviceId = event.deviceIdentifier;
		}

		if ([event.deviceIdentifier isEqualToNumber:_initialMultitouchDeviceId]) {
			[self resetInputTimers];

			if (!_detectInputTimer && event.touches.count == 0) {
				_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_setupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
			}
			else {
				BOOL shouldDraw = ([_lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > 16);

				for (MultitouchTouch *touch in event.touches) {
					float combinedTouchVelocity = fabs(touch.velX) + fabs(touch.velY);
					if (touch.state == 4 && combinedTouchVelocity > 0.06) {
						NSPoint drawPoint = NSMakePoint(touch.x, touch.y);

						NSNumber *identity = touch.identifier;

						if (!_gestureStrokes[identity]) {
							if (_orderedStrokeIds.count < 3) {
								[_orderedStrokeIds addObject:identity];
								_gestureStrokes[identity] = [[GestureStroke alloc] init];
							}
							else {
								continue;
							}
						}

						GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:drawPoint.x * GUBoundingBoxSize andY:drawPoint.y * GUBoundingBoxSize andStrokeId:[identity intValue]];

						[_gestureStrokes[identity] addPoint:detectorPoint];

						drawPoint.x *= self.frame.size.width;
						drawPoint.y *= self.frame.size.height;

						NSBezierPath *tempPath;
						if ((tempPath = _touchPaths[identity])) {
							[tempPath lineToPoint:drawPoint];
						}
						else {
							tempPath = [NSBezierPath bezierPath];
							[tempPath setLineWidth:6.0];
							[tempPath setLineCapStyle:NSRoundLineCapStyle];
							[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
							[tempPath moveToPoint:drawPoint];

							_touchPaths[identity] = tempPath;
						}
					}
				}

				if (shouldDraw) {
					[self setNeedsDisplay:YES];
					_lastMultitouchRedraw = [NSDate date];
				}
			}
		}
		else if (!_detectInputTimer) {
			_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:((float)_setupController.setupModel.readingDelayTime) / 1000.0 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
		}
	}
}

- (void)startMultitouchInput {
	[[MultitouchManager sharedMultitouchManager] addMultitouchListenerWithTarget:self callback:@selector(dealWithMultitouchEvent:) andThread:nil];
}

- (void)startDetectingGesture {
	[self resetAll];

	_mouseStrokeIndex = 0;

	_initialMultitouchDeviceId = nil;

	[_setupController showDrawNotification:YES];

	_noInputTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];

	[self becomeFirstResponder];

	if (_setupController.setupModel.multitouchOption) {
		[NSApp activateIgnoringOtherApps:YES];
		CGAssociateMouseAndMouseCursorPosition(NO);

		_startInputTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startMultitouchInput) userInfo:nil repeats:NO];
	}

	_detectingInput = YES;
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGestureIgnore {
	[self finishDetectingGesture:YES];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	_detectingInput = NO;

	if (_setupController.setupModel.multitouchOption) {
		[[MultitouchManager sharedMultitouchManager] removeMultitouchListenersWithTarget:self andCallback:@selector(dealWithMultitouchEvent:)];
		CGAssociateMouseAndMouseCursorPosition(YES);
	}

	if (!ignore) {
		NSMutableArray *orderedStrokes = [NSMutableArray array];
		for (int i = 0; i < _orderedStrokeIds.count; i++) {
			[orderedStrokes addObject:_gestureStrokes[_orderedStrokeIds[i]]];
		}

		[_setupController saveGestureWithStrokes:orderedStrokes];
	}

	[self resetAll];
}

- (void)showGesture:(Gesture *)gesture {
	_showingStoredGesture = YES;

	[self resetAll];
	if (gesture) {
		int pointIndex = 0;
		while (YES) {
			if ([[NSThread currentThread] isCancelled] || _detectingInput) {
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
				GestureStroke *cStroke = gesture.strokes[strokeIndex];
				if (pointIndex < cStroke.pointCount) {
					GesturePoint *cPoint = cStroke.points[pointIndex];

					NSPoint drawPoint = NSMakePoint(cPoint.x / GUBoundingBoxSize * self.frame.size.width, cPoint.y / GUBoundingBoxSize * self.frame.size.height);

					NSString *ident = [NSString stringWithFormat:@"%i", strokeIndex];

					if (pointIndex == 1) {
						NSBezierPath *tempPath = [NSBezierPath bezierPath];
						[tempPath setLineWidth:6.0];
						[tempPath setLineCapStyle:NSRoundLineCapStyle];
						[tempPath setLineJoinStyle:NSRoundLineJoinStyle];
						[tempPath moveToPoint:drawPoint];
						_touchPaths[ident] = tempPath;
					}
					else if (pointIndex > 1 && pointIndex < cStroke.pointCount) {
						NSBezierPath *tempPath = _touchPaths[ident];
						[tempPath lineToPoint:drawPoint];
					}
					else if (pointIndex == cStroke.pointCount) {
						NSBezierPath *tempPath = _touchPaths[ident];
						[tempPath lineToPoint:drawPoint];
						[_touchPaths removeObjectForKey:ident];
					}
				}
			}

			[NSThread sleepForTimeInterval:0.006];
		}
	}

	_showingStoredGesture = NO;
}

- (BOOL)resignFirstResponder {
	[self finishDetectingGesture:YES];

	return YES;
}

- (void)resetInputTimers {
	if (_startInputTimer) {
		[_startInputTimer invalidate];
		_startInputTimer = nil;
	}

	if (_noInputTimer) {
		[_noInputTimer invalidate];
		_noInputTimer = nil;
	}

	if (_detectInputTimer) {
		[_detectInputTimer invalidate];
		_detectInputTimer = nil;
	}
}

- (void)resetAll {
	[_setupController showDrawNotification:NO];

	[self resetInputTimers];

	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];
	_touchPaths = [NSMutableDictionary dictionary];

	_lastMultitouchRedraw = [NSDate date];

	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)canBecomeKeyView {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (_detectingInput || _showingStoredGesture) {
		for (NSBezierPath *path in[_touchPaths allValues]) {
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
