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
			int last = [order[(count - 1)] intValue];
			if (count % 2 == 1) {
				int first = [order[0] intValue];
				order[0] = @(last);
				order[(count - 1)] = @(first);
			}
			else {
				int next = [order[i] intValue];
				order[i] = @(last);
				order[(count - 1)] = @(next);
			}
		}
	}

	return newOrders;
}

NSMutableArray *GUMakeUnistrokes(NSMutableArray *strokes, NSMutableArray *orders) {
	NSMutableArray *unistrokes = [NSMutableArray array];
	for (int r = 0; r < orders.count; r++) {
		NSMutableArray *strokeOrder = orders[r];

		for (int b = 0; b < pow(2, strokeOrder.count); b++) {
			GestureStroke *unistroke = [[GestureStroke alloc] init];

			for (int i = 0; i < strokeOrder.count; i++) {
				int strokeIndex = [strokeOrder[i] intValue];
				GestureStroke *stroke = strokes[strokeIndex];

				NSMutableArray *copyOfStrokePoints = [[stroke points] mutableCopy];

				NSArray *points;
				if (((b >> i) & 1) == 1) {
					points = [[copyOfStrokePoints reverseObjectEnumerator] allObjects];
				}
				else {
					points = copyOfStrokePoints;
				}

				for (int p = 0; p < points.count; p++) {
					[unistroke addPoint:points[p]];
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
	for (int i = 0; i < points.pointCount; i++) {
		GesturePoint *point = [points pointAtIndex:i];
		float rotatedX = (point.x - centroid.x) * cosValue - (point.y - centroid.y) * sinValue + centroid.x;
		float rotatedY = (point.x - centroid.x) * sinValue + (point.y - centroid.y) * cosValue + centroid.y;

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

	for (int i = 1; i < currentPoints.pointCount; i++) {
		GesturePoint *point1 = [currentPoints pointAtIndex:(i - 1)];
		GesturePoint *point2 = [currentPoints pointAtIndex:i];
		float d = GUDistance(point1, point2);

		if ((initialDistance + d) > newPointDistance) {
			float x = point1.x + ((newPointDistance - initialDistance) / d) * (point2.x - point1.x);
			float y = point1.y + ((newPointDistance - initialDistance) / d) * (point2.y - point1.y);

			GesturePoint *newPoint = [[GesturePoint alloc] initWithX:x andY:y andStrokeId:point1.strokeId];
			[newPoints addPoint:newPoint];

			[currentPoints insertPoint:newPoint atIndex:i];

			initialDistance = 0.0;
		}
		else {
			initialDistance += d;
		}
	}

	if (newPoints.pointCount < GUResampledStrokePointCount) {
		GesturePoint *lastPoint = [points pointAtIndex:points.pointCount - 1];
		for (int j = 0; j < (GUResampledStrokePointCount - newPoints.pointCount); j++) {
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
			scaledX = point.x * scale;
			scaledY = point.y * scale;
		}
		else {
			scaledX = point.x * (GUBoundingBoxSize / currentBox.size.width);
			scaledY = point.y * (GUBoundingBoxSize / currentBox.size.height);
		}

		[scaled addPoint:[[GesturePoint alloc] initWithX:scaledX andY:scaledY andStrokeId:point.strokeId]];
	}

	return scaled;
}

GestureStroke *GUTranslateToOrigin(GestureStroke *points) {
	GesturePoint *centroid = GUCentroid(points);
	GestureStroke *translated = [[GestureStroke alloc] init];

	for (int i = 0; i < points.pointCount; i++) {
		GesturePoint *point = [points pointAtIndex:i];
		float translatedX = point.x - centroid.x;
		float translatedY = point.y - centroid.y;
		[translated addPoint:[[GesturePoint alloc] initWithX:translatedX andY:translatedY andStrokeId:point.strokeId]];
	}

	return translated;
}

float GUAngleBetweenUnitVectors(GesturePoint *unitVector1, GesturePoint *unitVector2) {
	float angle = (unitVector1.x * unitVector2.x + unitVector1.y * unitVector2.y);
	if (angle < -1.0 || angle > 1.0) {
		angle = GURoundToDigits(angle, 5);
	}

	return acos(angle);
}

float GUPathDistance(GestureStroke *points1, GestureStroke *points2) {
	float distance = 0.0;
	for (int i = 0; i < points1.pointCount && i < points2.pointCount; i++) {
		distance += GUDistance([points1 pointAtIndex:i], [points2 pointAtIndex:i]);
	}

	return distance / points1.pointCount;
}

GesturePoint *GUCalcStartUnitVector(GestureStroke *points) {
	int endPointIndex = GUStartVectorDelay + GUStartVectorLength;
	GesturePoint *pointAtIndex = [points pointAtIndex:endPointIndex];
	GesturePoint *firstPoint = [points pointAtIndex:GUStartVectorDelay];

	GesturePoint *unitVector = [[GesturePoint alloc] initWithX:pointAtIndex.x - firstPoint.x andY:pointAtIndex.y - firstPoint.y andStrokeId:0];
	float magnitude = sqrtf(unitVector.x * unitVector.x + unitVector.y * unitVector.y);

	return [[GesturePoint alloc] initWithX:unitVector.x / magnitude andY:unitVector.y / magnitude andStrokeId:0];
}

CGRect GUBoundingBox(GestureStroke *points) {
	float minX = FLT_MAX;
	float maxX = -FLT_MAX;
	float minY = FLT_MAX;
	float maxY = -FLT_MAX;

	for (GesturePoint *point in points.points) {
		if (point.x < minX) {
			minX = point.x;
		}

		if (point.y < minY) {
			minY = point.y;
		}

		if (point.x > maxX) {
			maxX = point.x;
		}

		if (point.y > maxY) {
			maxY = point.y;
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
	for (int i = 1; i < points.pointCount; i++) {
		GesturePoint *point1 = [points pointAtIndex:(i - 1)];
		GesturePoint *point2 = [points pointAtIndex:i];
		distance += GUDistance(point1, point2);
	}

	return distance;
}

float GUDistance(GesturePoint *point1, GesturePoint *point2) {
	int xDiff = point2.x - point1.x;
	int yDiff = point2.y - point1.y;
	float dist = sqrt(xDiff * xDiff + yDiff * yDiff);
	return dist;
}

GesturePoint *GUCentroid(GestureStroke *points) {
	float x = 0.0;
	float y = 0.0;
	for (GesturePoint *point in points.points) {
		x += point.x;
		y += point.y;
	}

	x /= points.pointCount;
	y /= points.pointCount;

	return [[GesturePoint alloc] initWithX:x andY:y andStrokeId:0];
}
