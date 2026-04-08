package gjk

import "core:math"
import lin "core:math/linalg"
import "core:testing"

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
	pos:      Point,
	vertices: [dynamic; MAX_VERTICES]Vec2,
}

polygon_support :: proc(polygon: Polygon, dir: Direction) -> Point {
	largest_dist: f32 = -math.INF_F32
	farthest_idx: int = 0
	for vertex, idx in polygon.vertices {
		prod := lin.dot(dir, vertex)
		if prod > largest_dist {
			largest_dist = prod
			farthest_idx = idx
		}
	}

	return polygon.vertices[farthest_idx] + polygon.pos
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

minkowski_difference :: proc(shape_a: Shape, shape_b: Shape, dir: Direction) -> Point {
	return shape_support(shape_a, dir) - shape_support(shape_b, -dir)
}

// ------------------------- TESTS ------------------------- //

@(test)
test_circle_support_up :: proc(t: ^testing.T) {
	circle := Circle {
		center = {0, 0},
		radius = 1,
	}

	p := shape_support(circle, {0, 1})

	testing.expect_value(t, p, Point{0, 1})
}

@(test)
test_circle_support_right :: proc(t: ^testing.T) {
	circle := Circle {
		center = {0, 0},
		radius = 1,
	}

	p := shape_support(circle, {1, 0})
	testing.expect_value(t, p, Point{1, 0})
}

@(test)
test_circle_support_diagonal :: proc(t: ^testing.T) {
	circle := Circle {
		center = {0, 0},
		radius = 1,
	}

	dir := Vec2{1, 1}
	p := shape_support(circle, dir)

	testing.expect_value(t, p, Vec2{1 / math.sqrt_f32(2), 1 / math.sqrt_f32(2)})
}

@(test)
test_circle_support_neg_diagonal :: proc(t: ^testing.T) {
	circle := Circle {
		center = {0, 0},
		radius = 1,
	}

	dir := Vec2{-1, -1}
	p := shape_support(circle, dir)

	testing.expect_value(t, p, Vec2{-1 / math.sqrt_f32(2), -1 / math.sqrt_f32(2)})
}

@(test)
test_polygon_support_square_dir_towards_corners :: proc(t: ^testing.T) {
	square := Polygon {
		pos      = {0, 0},
		vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}},
	}

	// Testing with directions exactly towards the corners
	// Upper right corner
	dir_ur := Vec2{1, 1}
	p_ur := shape_support(square, dir_ur)
	testing.expect_value(t, p_ur, Vec2{1, 1})

	// Lower right corner
	dir_lr := Vec2{1, -1}
	p_lr := shape_support(square, dir_lr)
	testing.expect_value(t, p_lr, Vec2{1, -1})

	// Lower left corner
	dir_ll := Vec2{-1, -1}
	p_ll := shape_support(square, dir_ll)
	testing.expect_value(t, p_ll, Vec2{-1, -1})

	// Upper left corner
	dir_ul := Vec2{-1, 1}
	p_ul := shape_support(square, dir_ul)
	testing.expect_value(t, p_ul, Vec2{-1, 1})
}

@(test)
test_polygon_support_square_dir_close_towards_corners :: proc(t: ^testing.T) {
	square := Polygon {
		pos      = {0, 0},
		vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}},
	}

	// Testing with directions closely towards the corners
	// Upper right corner
	dir_ur := Vec2{0.8, 0.8}
	p_ur := shape_support(square, dir_ur)
	testing.expect_value(t, p_ur, Vec2{1, 1})

	// Lower right corner
	dir_lr := Vec2{0.7, -0.9}
	p_lr := shape_support(square, dir_lr)
	testing.expect_value(t, p_lr, Vec2{1, -1})

	// Lower left corner
	dir_ll := Vec2{-1, -0.8}
	p_ll := shape_support(square, dir_ll)
	testing.expect_value(t, p_ll, Vec2{-1, -1})

	// Upper left corner
	dir_ul := Vec2{-0.7, 0.8}
	p_ul := shape_support(square, dir_ul)
	testing.expect_value(t, p_ul, Vec2{-1, 1})
}

@(test)
test_minkowski_difference :: proc(t: ^testing.T) {
	c1 := Circle {
		center = {0, 0},
		radius = 1,
	}

	c2 := Circle {
		center = {3, 0},
		radius = 1,
	}

	diff := minkowski_difference(c1, c2, Vec2{1, 0})

	// support(c1) -> {1, 0}
	// support(c2) -> {2, 0}
	// {1, 0} - {2, 0} = {-1, 0}
	testing.expect_value(t, diff, Vec2{-1, 0})
}
