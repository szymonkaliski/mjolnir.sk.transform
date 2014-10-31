#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <lauxlib.h>

#import "animation.h"

extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);

#define get_window_arg(L, idx) *((AXUIElementRef*)luaL_checkudata(L, idx, "mjolnir.window"))

static NSSize geom_tosize(lua_State* L, int idx) {
	luaL_checktype(L, idx, LUA_TTABLE);
	CGFloat w = (lua_getfield(L, idx, "w"), luaL_checknumber(L, -1));
	CGFloat h = (lua_getfield(L, idx, "h"), luaL_checknumber(L, -1));
	lua_pop(L, 2);
	return NSMakeSize(w, h);
}

static NSPoint geom_topoint(lua_State* L, int idx) {
	luaL_checktype(L, idx, LUA_TTABLE);
	CGFloat x = (lua_getfield(L, idx, "x"), luaL_checknumber(L, -1));
	CGFloat y = (lua_getfield(L, idx, "y"), luaL_checknumber(L, -1));
	lua_pop(L, 2);
	return NSMakePoint(x, y);
}

static float get_float(lua_State* L, int idx) {
	luaL_checktype(L, idx, LUA_TNUMBER);
	float result = lua_tonumber(L, idx);
	lua_pop(L, 1);
	return result;
}

static NSPoint get_window_topleft(AXUIElementRef win) {
	CFTypeRef positionStorage;
	AXError result = AXUIElementCopyAttributeValue(win, (CFStringRef)NSAccessibilityPositionAttribute, &positionStorage);

	CGPoint topLeft;
	if (result == kAXErrorSuccess) {
		if (!AXValueGetValue(positionStorage, kAXValueCGPointType, (void *)&topLeft)) {
			topLeft = CGPointZero;
		}
	}
	else {
		topLeft = CGPointZero;
	}

	if (positionStorage) CFRelease(positionStorage);

	return (NSPoint)topLeft;
}

static NSSize get_window_size(AXUIElementRef win) {
	CFTypeRef sizeStorage;
	AXError result = AXUIElementCopyAttributeValue(win, (CFStringRef)NSAccessibilitySizeAttribute, &sizeStorage);

	CGSize size;
	if (result == kAXErrorSuccess) {
		if (!AXValueGetValue(sizeStorage, kAXValueCGSizeType, (void *)&size)) {
			size = CGSizeZero;
		}
	}
	else {
		size = CGSizeZero;
	}

	if (sizeStorage) CFRelease(sizeStorage);

	return (NSSize)size;
}

static int window_transform(lua_State* L) {
	AXUIElementRef win = get_window_arg(L, 1);

	NSPoint thePoint = geom_topoint(L, 2);
	NSSize theSize = geom_tosize(L, 3);

	float duration = get_float(L, 4);

	NSPoint oldTopLeft = get_window_topleft(win);
	NSSize oldSize = get_window_size(win);

	TransformAnimation *anim = [[TransformAnimation alloc] initWithDuration:duration animationCurve:NSAnimationEaseInOut];

	[anim setOldTopLeft:oldTopLeft];
	[anim setNewTopLeft:thePoint];
	[anim setOldSize:oldSize];
	[anim setNewSize:theSize];
	[anim setWindow:win];

	/* [anim setAnimationBlockingMode:NSAnimationNonblocking]; */

	[anim setFrameRate: 60.0];
	[anim startAnimation];

	return 0;
}

static const luaL_Reg transformLib[] = {
	{"transform", window_transform},

	{} // necessary sentinel
};

int luaopen_mjolnir_sk_transform_internal(lua_State* L) {
	luaL_newlib(L, transformLib);
	return 1;
}
