package gjk

import lin "core:math/linalg"

Vec2 :: [2]f32

Point :: Vec2
Direction :: Vec2

Circle :: struct {
	center: Vec2,
	radius: f32,
}

circle_support :: proc(circle: Circle, dir: Direction) -> Point {
	//NOTE(Thomas) Return the center if the direction is a zero vector, because
	// lin.normalize(dir) will behave badly.
	if dir == {0, 0} {
		return circle.center
	}
	p := circle.center + lin.normalize(dir) * circle.radius
	return p
}

MAX_VERTICES :: 64
Polygon :: struct {
	vertices: [dynamic; MAX_VERTICES]Vec2,
}

polygon_support :: proc(polygon: Polygon, dir: Direction) -> Point {
	return Point{}
}

Shape :: union {
	Circle,
	Polygon,
}

shape_support :: proc(shape: Shape, dir: Direction) -> Point {
	p: Point
	switch s in shape {
	case Circle:
		p = circle_support(s, dir)
	case Polygon:
		p = polygon_support(s, dir)
	}
	return p
}
