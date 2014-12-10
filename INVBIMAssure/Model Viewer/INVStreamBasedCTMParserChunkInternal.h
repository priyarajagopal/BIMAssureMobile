#import "INVStreamBasedCTMParserChunk.h"

#if TARGET_IPHONE_SIMULATOR

typedef float vertex_position_element_type;
typedef float vertex_normal_element_type;
typedef float vertex_color_element_type;

#else

typedef float vertex_position_element_type;
typedef float vertex_normal_element_type;
typedef float vertex_color_element_type;

#endif

typedef uint16_t index_index_type;

struct __attribute__((packed)) vertex_struct {
    vertex_position_element_type position[3];
    vertex_normal_element_type normal[3];
    vertex_color_element_type color[4];
};

struct __attribute__((packed)) index_struct {
    index_index_type index;
};