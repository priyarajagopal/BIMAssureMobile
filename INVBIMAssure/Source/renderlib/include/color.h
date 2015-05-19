#pragma once

#include <stdint.h>

namespace renderlib {

class RGBA
{
public:
	RGBA(): r_(0), g_(0), b_(0), a_(0) {}
	RGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a): r_(r), g_(g), b_(b), a_(a) {}
	RGBA(uint32_t color) :
		a_((color >> 24) & 0xff),
		r_((color >> 16) & 0xff),
		g_((color >> 8) & 0xff),
		b_(color & 0xff)
	{
		// in our json file, when the alpha component does not exist, 
		// it is a fully opaque color
		if (a_ == 0)
			a_ = 255;
	}
	
	uint8_t r() const { return r_; }
    uint8_t g() const { return g_; }
    uint8_t b() const { return b_; }
	uint8_t a() const { return a_; }
	
	uint8_t& r() { return r_; }
    uint8_t& g() { return g_; }
    uint8_t& b() { return b_; }
	uint8_t& a() { return a_; }

	bool is_transparent() const		
	{
		return (a_ < 255);
	}

	static const RGBA SELECT_COLOR;
	static const RGBA INVISIBLE_COLOR;
	static const RGBA GLASS_COLOR;

private:
	uint8_t r_, g_, b_, a_;
};

}