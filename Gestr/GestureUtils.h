#import <Foundation/Foundation.h>
#import "GestureStroke.h"
#import "GesturePoint.h"

#define boundingBoxSize 400

#define GoldenRatio (0.5 * (-1.0 + sqrt(5.0)))

#define startVectorDelay 2
#define startVectorLength 10

#define minimumPointCount 13

#define scaleLeniency 0.25f

#define resampledStrokePointCount 120

#define goldenRatioAngleLeniency 30.0f

#define startAngleLeniency 30.0f

#define goldenRatioDegreeConstant 2.0f

float DistanceAtBestAngle(GestureStroke *inputPoints, GestureStroke *matchPoints);
NSMutableArray *HeapPermute(int count, NSMutableArray *order, NSMutableArray *newOrders);
NSMutableArray *MakeUnistrokes(NSMutableArray *strokes, NSMutableArray *orders);
GestureStroke *RotateBy(GestureStroke *points, float radians);
GestureStroke *Resample(GestureStroke *points);
GestureStroke *Scale(GestureStroke *points);
GestureStroke *TranslateToOrigin(GestureStroke *points);
GestureStroke *Splice(GestureStroke *originalPoints, id newVal, int i);
float AngleBetweenUnitVectors(GesturePoint *unitVector1, GesturePoint *unitVector2);
float PathDistance(GestureStroke *points1, GestureStroke *points2);
GesturePoint *CalcStartUnitVector(GestureStroke *points);
CGRect BoundingBox(GestureStroke *points);
float DistanceAtAngle(GestureStroke *recognizingPoints, GestureStroke *matchPoints, float radians);
float RoundToDigits(float number, int decimals);
float DegreesToRadians(float degrees);
float RadiansToDegrees(float radians);
float PathLength(GestureStroke *points);
float Distance(GesturePoint *point1, GesturePoint *point2);
GesturePoint *Centroid(GestureStroke *points);
