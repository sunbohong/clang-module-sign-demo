
@import A;
#if !__building_module(B)
#error "should only get here when building module B"
#endif

const int b = 2;
