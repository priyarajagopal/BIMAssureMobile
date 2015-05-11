#pragma once

#include "element_id.h"
#include "camera.h"

namespace renderlib {

class Renderer;
class ElementManager;
class Framebuffer;

class Viewer 
{
public:
	Viewer();
	~Viewer();
	void init();
	void set_viewport(int x, int y, int w, int h);
	bool draw();
	void request_render();
	Renderer* get_renderer() const { return renderer; }

	void set_cache_folder(const char* folder);
	void set_auth_token(const char* token);
	bool load_model(const char* url);
	void cancel_load_model();
	void clear();

	Camera& get_camera() { return camera; }
	void reset_camera();
	void set_camera_preset_position(CameraPresetPosition pos);
	void fit_camera_to_box(const Box& box);

	void set_elements_selected(const ElementIdList& ids, bool selected);
	void deselect_all_elements();
	ElementIdList get_selected_elements();
	
	void set_elements_visible(const ElementIdList& ids, bool visible);
	bool is_element_visible(const ElementId& id) const;

	ElementId pick_element_on_screen(double x, double y);

	void set_glass_mode(bool enable);
	bool is_glass_mode() const { return glass_mode; }

	void on_mouse_down(int button, double x, double y);
	void on_mouse_move(double x, double y);
	void on_mouse_up(int button, double x, double y);
	void on_mouse_wheel(double delta);

	void on_touch_begin(size_t num_touches, glm::vec2* touch_points);
	void on_touch_move(size_t num_touches, glm::vec2* touch_points);
	void on_touch_end(size_t num_touches, glm::vec2* touch_points);

private:
	Camera camera;
	Renderer* renderer;
	ElementManager* element_manager;
	Framebuffer* frame_buffer;
	int viewport_x, viewport_y, viewport_w, viewport_h;
	bool need_render;
	bool glass_mode;

	glm::vec2 normalizeWindowPos(double x, double y);
};

}
