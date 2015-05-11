#pragma once

#include "glm/glm.hpp"
#include "box.h"

namespace renderlib {

enum CameraPresetPosition
{
	CAMERA_ISO=0, CAMERA_TOP, CAMERA_BOTTOM, CAMERA_LEFT, CAMERA_RIGHT, CAMERA_FRONT, CAMERA_BACK
};

class Camera
{
public:
	Camera();
	void set_size(int width, int height);
	glm::mat4 get_view_matrix() const;
	glm::mat4 get_projection_matrix() const;
	void zoom_box(const Box& box);
	void reset_position();
	void set_preset_position(CameraPresetPosition pos);

	void orbit(const float dx, const float dy);
	void pan(const float dx, const float dy);
	void dolly(const float delta, const Box& bbox);

	glm::vec3 position;
	glm::vec3 target;
	glm::vec3 up;
	
	float fov;
	float width;
	float height;
	float near;
	float far;
};

}
