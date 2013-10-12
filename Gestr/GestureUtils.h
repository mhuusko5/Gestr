#import <Foundation/Foundation.h>
#import "GestureStroke.h"
#import "GesturePoint.h"

#define GUBoundingBoxSize 400

#define GUGoldenRatio (0.5 * (-1.0 + sqrt(5.0)))

#define GUStartVectorDelay 2
#define GUStartVectorLength 10

#define GUMinimumPointCount 13

#define GUScaleLeniency 0.25f

#define GUResampledStrokePointCount 160

#define GUGoldenRatioAngleLeniency 30.0f

#define GUStartAngleLeniency 40.0f

#define GUGoldenRatioDegreeConstant 2.0f

float GUDistanceAtBestAngle(GestureStroke *inputPoints, GestureStroke *matchPoints);
NSMutableArray *GUHeapPermute(int count, NSMutableArray *order, NSMutableArray *newOrders);
NSMutableArray *GUMakeUnistrokes(NSMutableArray *strokes, NSMutableArray *orders);
GestureStroke *GURotateBy(GestureStroke *points, float radians);
GestureStroke *GUResample(GestureStroke *points);
GestureStroke *GUScale(GestureStroke *points);
GestureStroke *GUTranslateToOrigin(GestureStroke *points);
GestureStroke *GUSplice(GestureStroke *originalPoints, id newVal, int i);
float GUAngleBetweenUnitVectors(GesturePoint *unitVector1, GesturePoint *unitVector2);
float GUPathDistance(GestureStroke *points1, GestureStroke *points2);
GesturePoint *GUCalcStartUnitVector(GestureStroke *points);
CGRect GUBoundingBox(GestureStroke *points);
float GUDistanceAtAngle(GestureStroke *recognizingPoints, GestureStroke *matchPoints, float radians);
float GURoundToDigits(float number, int decimals);
float GUDegreesToRadians(float degrees);
float GURadiansToDegrees(float radians);
float GUPathLength(GestureStroke *points);
float GUDistance(GesturePoint *point1, GesturePoint *point2);
GesturePoint *GUCentroid(GestureStroke *points);
