#import "GestureUtils.h"

float GUDistanceAtBestAngle(GestureStroke *inputPoints, GestureStroke *matchPoints) {
	float minAngleRange = GUDegreesToRadians(-GUGoldenRatioAngleLeniency);
	float maxAngleRange = GUDegreesToRadians(GUGoldenRatioAngleLeniency);
    
	float x1 = GUGoldenRatio * minAngleRange + (1.0 - GUGoldenRatio) * maxAngleRange;
	float f1 = GUDistanceAtAngle(inputPoints, matchPoints, x1);
	float x2 = (1.0 - GUGoldenRatio) * minAngleRange + GUGoldenRatio * maxAngleRange;
	float f2 = GUDistanceAtAngle(inputPoints, matchPoints, x2);
	while (abs(maxAngleRange - minAngleRange) > GUDegreesToRadians(GUGoldenRatioDegreeConstant)) {
		if (f1 < f2) {
			maxAngleRange = x2;
			x2 = x1;
			f2 = f1;
			x1 = GUGoldenRatio * minAngleRange + (1.0 - GUGoldenRatio) * maxAngleRange;
			f1 = GUDistanceAtAngle(inputPoints, matchPoints, x1);
		}
		else {
			minAngleRange = x1;
			x1 = x2;
			f1 = f2;
			x2 = (1.0 - GUGoldenRatio) * minAngleRange + GUGoldenRatio * maxAngleRange;
			f2 = GUDistanceAtAngle(inputPoints, matchPoints, x2);
		}
	}
    
	return MIN(f1, f2);
}

NSMutableArray *GUHeapPermute(int count, NSMutableArray *order, NSMutableArray *newOrders) {
	if (count == 1) {
		[newOrders addObject:[order copy]];
	}
	else {
		for (int i = 0; i < count; i++) {
			GUHeapPermute(count - 1, order, newOrders);
			int last = [[order objectAtIndex:(count - 1)] intValue];
			if (count % 2 == 1) {
				int first = [[order objectAtIndex:0] intValue];
				[order replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:last]];
				[order replaceObjectAtIndex:(count - 1) withObject:[NSNumber numberWithInt:first]];
			}
			else {
				int next = [[order objectAtIndex:i] intValue];
				[order replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:last]];
				[order replaceObjectAtIndex:(count - 1) withObject:[NSNumber numberWithInt:next]];
			}
		}
	}
    
	return newOrders;
}

NSMutableArray *GUMakeUnistrokes(NSMutableArray *strokes, NSMutableArray *orders) {
	NSMutableArray *unistrokes = [NSMutableArray array];
	for (int r = 0; r < orders.count; r++) {
		NSMutableArray *strokeOrder = [orders objectAtIndex:r];
        
		for (int b = 0; b < pow(2, strokeOrder.count); b++) {
			GestureStroke *unistroke = [[GestureStroke alloc] init];
            
			for (int i = 0; i < strokeOrder.count; i++) {
				NSArray *points = [NSArray array];
				int strokeIndex = [[strokeOrder objectAtIndex:i] intValue];
				GestureStroke *stroke = [strokes objectAtIndex:strokeIndex];
                
				NSMutableArray *copyOfStrokePoints = [NSMutableArray arrayWithArray:[[stroke points] copy]];
				if (((b >> i) & 1) == 1) {
					points = [[copyOfStrokePoints reverseObjectEnumerator] allObjects];
				}
				else {
					points = copyOfStrokePoints;
				}
                
				for (int p = 0; p < points.count; p++) {
					[unistroke addPoint:[points objectAtIndex:p]];
				}
			}
            
			[unistrokes addObject:unistroke];
		}
	}
    
	return unistrokes;
}

GestureStroke *GURotateBy(GestureStroke *points, float radians) {
	GesturePoint *centroid = GUCentroid(points);
	float cosValue = cosf(radians);
	float sinValue = sinf(radians);
    
	GestureStroke *rotatedPoints = [[GestureStroke alloc] init];
	for (int i = 0; i < [points pointCount]; i++) {
		GesturePoint *point = [points pointAtIndex:i];
		float rotatedX = ([point getX] - [centroid getX]) * cosValue - ([point getY] - [centroid getY]) * sinValue + [centroid getX];
		float rotatedY = ([point getX] - [centroid getX]) * sinValue + ([point getY] - [centroid getY]) * cosValue + [centroid getY];
        
		[rotatedPoints addPoint:[[GesturePoint alloc] initWithX:rotatedX andY:rotatedY andStrokeId:point.strokeId]];
	}
    
	return rotatedPoints;
}

GestureStroke *GUResample(GestureStroke *points) {
	GestureStroke *currentPoints = [points copy];
	GestureStroke *newPoints = [[GestureStroke alloc] init];
	[newPoints addPoint:[points pointAtIndex:0]];
    
	float newPointDistance = GUPathLength(points) / (GUResampledStrokePointCount - 1);
	float initialDistance = 0.0;
    
	for (int i = 1; i < [currentPoints pointCount]; i++) {
		GesturePoint *point1 = [currentPoints pointAtIndex:(i - 1)];
		GesturePoint *point2 = [currentPoints pointAtIndex:i];
		float d = GUDistance(point1, point2);
        
		if ((initialDistance + d) > newPointDistance) {
			float x = [point1 getX] + ((newPointDistance - initialDistance) / d) * ([point2 getX] - [point1 getX]);
			float y = [point1 getY] + ((newPointDistance - initialDistance) / d) * ([point2 getY] - [point1 getY]);
            
			GesturePoint *newPoint = [[GesturePoint alloc] initWithX:x andY:y andStrokeId:point1.strokeId];
			[newPoints addPoint:newPoint];
            
			currentPoints = GUSplice(currentPoints, newPoint, i);
            
			initialDistance = 0.0;
		}
		else {
			initialDistance += d;
		}
	}
    
	if ([newPoints pointCount] < GUResampledStrokePointCount) {
		GesturePoint *lastPoint = [points pointAtIndex:[points pointCount] - 1];
		for (int j = 0; j < (GUResampledStrokePointCount - [newPoints pointCount]); j++) {
			[newPoints addPoint:[lastPoint copy]];
		}
	}
    
	return newPoints;
}

GestureStroke *GUScale(GestureStroke *points) {
	CGRect currentBox = GUBoundingBox(points);
	BOOL isLine = MIN(currentBox.size.width / currentBox.size.height, currentBox.size.height / currentBox.size.width) <= GUScaleLeniency;
    
	GestureStroke *scaled = [[GestureStroke alloc] init];
	for (GesturePoint *point in points.points) {
		float scale;
		float scaledX;
		float scaledY;
		if (isLine) {
			scale = (GUBoundingBoxSize / MAX(currentBox.size.width, currentBox.size.height));
			scaledX = [point getX] * scale;
			scaledY = [point getY] * scale;
		}
		else {
			scaledX = [point getX] * (GUBoundingBoxSize / currentBox.size.width);
			scaledY = [point getY] * (GUBoundingBoxSize / currentBox.size.height);
		}
        
		[scaled addPoint:[[GesturePoint alloc] initWithX:scaledX andY:scaledY andStrokeId:point.strokeId]];
	}
    
	return scaled;
}

GestureStroke *GUTranslateToOrigin(GestureStroke *points) {
	GesturePoint *centroid = GUCentroid(points);
	GestureStroke *translated = [[GestureStroke alloc] init];
	for (int i = 0; i < [points pointCount]; i++) {
		GesturePoint *point = [points pointAtIndex:i];
		float translatedX = [point getX] - [centroid getX];
		float translatedY = [point getY] - [centroid getY];
		[translated addPoint:[[GesturePoint alloc] initWithX:translatedX andY:translatedY andStrokeId:point.strokeId]];
	}
    
	return translated;
}

GestureStroke *GUSplice(GestureStroke *originalPoints, id newVal, int i) {
	NSArray *frontSlice = [originalPoints.points subarrayWithRange:NSMakeRange(0, i)];
	int len = (int)([originalPoints pointCount] - i);
	NSArray *backSlice = [originalPoints.points subarrayWithRange:NSMakeRange(i, len)];
    
	NSMutableArray *spliced = [NSMutableArray arrayWithArray:frontSlice];
	[spliced addObject:newVal];
	[spliced addObjectsFromArray:backSlice];
    
	return [[GestureStroke alloc] initWithPoints:spliced];
}

float GUAngleBetweenUnitVectors(GesturePoint *unitVector1, GesturePoint *unitVector2) {
	float angle = ([unitVector1 getX] * [unitVector2 getX] + [unitVector1 getY] * [unitVector2 getY]);
	if (angle < -1.0 || angle > 1.0) {
		angle = GURoundToDigits(angle, 5);
	}
    
	return acos(angle);
}

float GUPathDistance(GestureStroke *points1, GestureStroke *points2) {
	float distance = 0.0;
	for (int i = 0; i < [points1 pointCount] && i < [points2 pointCount]; i++) {
		distance += GUDistance([points1 pointAtIndex:i], [points2 pointAtIndex:i]);
	}
    
	return distance / [points1 pointCount];
}

GesturePoint *GUCalcStartUnitVector(GestureStroke *points) {
	int endPointIndex = GUStartVectorDelay + GUStartVectorLength;
	GesturePoint *pointAtIndex = [points pointAtIndex:endPointIndex];
	GesturePoint *firstPoint = [points pointAtIndex:GUStartVectorDelay];
    
	GesturePoint *unitVector = [[GesturePoint alloc] initWithX:[pointAtIndex getX] - [firstPoint getX] andY:[pointAtIndex getY] - [firstPoint getY] andStrokeId:0];
	float magnitude = sqrtf([unitVector getX] * [unitVector getX] + [unitVector getY] * [unitVector getY]);
    
	return [[GesturePoint alloc] initWithX:[unitVector getX] / magnitude andY:[unitVector getY] / magnitude andStrokeId:0];
}

CGRect GUBoundingBox(GestureStroke *points) {
	float minX = FLT_MAX;
	float maxX = -FLT_MAX;
	float minY = FLT_MAX;
	float maxY = -FLT_MAX;
    
	for (GesturePoint *point in points.points) {
		if ([point getX] < minX) {
			minX = [point getX];
		}
        
		if ([point getY] < minY) {
			minY = [point getY];
		}
        
		if ([point getX] > maxX) {
			maxX = [point getX];
		}
        
		if ([point getY] > maxY) {
			maxY = [point getY];
		}
	}
    
	return CGRectMake(minX, minY, (maxX - minX), (maxY - minY));
}

float GUDistanceAtAngle(GestureStroke *recognizingPoints, GestureStroke *matchPoints, float radians) {
	GestureStroke *newPoints = GURotateBy(recognizingPoints, radians);
	return GUPathDistance(newPoints, matchPoints);
}

float GURoundToDigits(float number, int decimals) {
	decimals = pow(10, decimals);
	return round(number * decimals) / decimals;
}

float GUDegreesToRadians(float degrees) {
	return degrees * M_PI / 180.0;
}

float GURadiansToDegrees(float radians) {
	return radians * 180.0 / M_PI;
}

float GUPathLength(GestureStroke *points) {
	float distance = 0.0;
	for (int i = 1; i < [points pointCount]; i++) {
		GesturePoint *point1 = [points pointAtIndex:(i - 1)];
		GesturePoint *point2 = [points pointAtIndex:i];
		distance += GUDistance(point1, point2);
	}
    
	return distance;
}

float GUDistance(GesturePoint *point1, GesturePoint *point2) {
	int xDiff = [point2 getX] - [point1 getX];
	int yDiff = [point2 getY] - [point1 getY];
	float dist = sqrt(xDiff * xDiff + yDiff * yDiff);
	return dist;
}

GesturePoint *GUCentroid(GestureStroke *points) {
	float x = 0.0;
	float y = 0.0;
	for (GesturePoint *point in points.points) {
		x += [point getX];
		y += [point getY];
	}
    
	x /= [points pointCount];
	y /= [points pointCount];
    
	return [[GesturePoint alloc] initWithX:x andY:y andStrokeId:0];
}
