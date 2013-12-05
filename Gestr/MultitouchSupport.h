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

    typedef struct {
        int frame;
        double timestamp;
        int identifier;
        int state;
        int unknown1;
        int unknown2;
        MTVector normalized;
        float size;
        int unknown3;
        float angle;
        float majorAxis;
        float minorAxis;
        MTVector unknown4;
        int unknown5[2];
        float unknown6;
    } MTTouch;

    typedef void *MTDeviceRef;
    typedef int (*MTContactCallbackFunction)(int, MTTouch *, int, double, int);

    MTDeviceRef MTDeviceCreateDefault();
    CFMutableArrayRef MTDeviceCreateList(void);

    void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
    void MTUnregisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);

    void MTDeviceStart(MTDeviceRef, int);
    void MTDeviceStop(MTDeviceRef);

    void MTDeviceRelease(MTDeviceRef);

#ifdef __cplusplus
}
#endif
