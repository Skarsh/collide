package main

import rl "vendor:raylib"

import "gjk"

Environment :: struct {}

Sim :: struct {
	camera:      rl.Camera2D,
	environment: Environment,
}

INITIAL_WIDTH :: 800
INITIAL_HEIGHT :: 600

main :: proc() {

	rl.InitWindow(INITIAL_WIDTH, INITIAL_HEIGHT, "Collide")
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(60)

	font := rl.LoadFontEx("resources/JetBrainsMono-Regular.ttf", 32, nil, 0)
	rl.SetTextureFilter(font.texture, .BILINEAR)
	rl.GuiSetFont(font)

	environment := Environment{}

	sim := Sim {
		camera = rl.Camera2D {
			target = {0, 0},
			offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			rotation = 0,
			zoom = 1,
		},
		environment = environment,
	}

	square := gjk.Polygon {
		pos      = {0, 0},
		vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}},
	}

	for !rl.WindowShouldClose() {

		// Update
		if rl.IsKeyPressed(.CAPS_LOCK) {
			break
		}

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		rl.EndDrawing()
	}

	rl.UnloadFont(font)
	rl.CloseWindow()
}
