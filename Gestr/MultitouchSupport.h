#ifdef __cplusplus
extern "C" {
#endif

    typedef struct {
        float x;
        float y;
    } MTPoint;

    typedef struct {
        MTPoint position;
        MTPoint velocity;
    } MTVector;

    enum {
        MTTouchStateNotTracking = 0,
        MTTouchStateStartInRange = 1,
        MTTouchStateHoverInRange = 2,
        MTTouchStateMakeTouch = 3,
        MTTouchStateTouching = 4,
        MTTouchStateBreakTouch = 5,
        MTTouchStateLingerInRange = 6,
        MTTouchStateOutOfRange = 7
    };
    typedef int MTTouchState;

    typedef struct {
        int frame;
        double timestamp;
        int identifier;
        MTTouchState state;
        int fingerId;
        int handId;
        MTVector normalizedPosition;
        float size;
        int field9;
        float angle;
        float majorAxis;
        float minorAxis;
        MTVector absolutePosition;
        int field14;
        int field15;
        float density;
    } MTTouch;

    typedef void *MTDeviceRef;

    typedef void (*MTFrameCallbackFunction)(MTDeviceRef device, MTTouch touches[], int numTouches, double timestamp, int frame);

    bool MTDeviceIsAvailable();
    CFMutableArrayRef MTDeviceCreateList();
    bool MTDeviceIsBuiltIn(MTDeviceRef) __attribute__((weak_import));

    void MTRegisterContactFrameCallback(MTDeviceRef, MTFrameCallbackFunction);
    void MTUnregisterContactFrameCallback(MTDeviceRef, MTFrameCallbackFunction);

    void MTDeviceStart(MTDeviceRef, int);
    void MTDeviceStop(MTDeviceRef);
    void MTDeviceRelease(MTDeviceRef);

#ifdef __cplusplus
}
#endif
