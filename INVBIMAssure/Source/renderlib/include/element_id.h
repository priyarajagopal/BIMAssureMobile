#pragma once

#include <string>
#include <vector>
#include <stdint.h>
#include "glm/gtc/constants.hpp"

namespace renderlib {

typedef uint32_t ElementId;
typedef std::vector<ElementId> ElementIdList;
typedef std::string SharedGeomId;

const float PI = glm::pi<float>();
const float EPS = glm::epsilon<float>();

enum ElementType { UNKNOWN, SPACES };

}