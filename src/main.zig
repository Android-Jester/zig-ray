const std = @import("std");
const lib = @import("./root.zig");
const ry = @import("raylib");
const vector3Normalize = ry.math.vector3Normalize;
const KeyBoard = ry.KeyboardKey;
const CameraMode = ry.CameraMode;
const Camera = ry.Camera;
const CameraProjection = ry.CameraProjection;
const Color = ry.Color;
const DEG2RAD: f32 = std.math.pi / 180.0;
const MAX_COLUMNS: u8 = 20;
pub fn main() void {
    const sWidth = 800;
    const sHeight = 800;
    var cameraMode: CameraMode = ry.CameraMode.camera_third_person;
    var heights: [MAX_COLUMNS]i32 = undefined;
    var positions: [MAX_COLUMNS]ry.Vector3 = undefined;
    var colors: [MAX_COLUMNS]ry.Color = undefined;
    ry.initWindow(sWidth, sHeight, "raylib-zig [Core]");
    defer ry.closeWindow();
    var camera: Camera = .{
        .position = ry.Vector3{ .x = 0.0, .y = 2.0, .z = 4.0 },
        .target = .{ .x = 0.0, .y = 2.0, .z = 0.0 },
        .fovy = 60.0,
        .projection = .camera_perspective,
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
    };
    for (0..MAX_COLUMNS) |i| {
        const posx: f32 = @floatFromInt(ry.getRandomValue(-15.0, 15.0));
        // const heightv: f32 = ;
        heights[i] = ry.getRandomValue(1, 12);
        positions[i] = .{ .x = posx, .y = @as(f32, @floatFromInt(heights[i])) / 2.0, .z = @floatFromInt(ry.getRandomValue(-15.0, 15.0)) };
        colors[i] = .{ .r = @intCast(ry.getRandomValue(20, 255)), .g = @intCast(ry.getRandomValue(10, 55)), .b = 30, .a = 255 };
        std.debug.print("[++] Colors: {any}", .{colors[i]});
    }
    ry.disableCursor();

    ry.setTargetFPS(30);
    while (!ry.windowShouldClose()) {
        if (ry.isKeyPressed(KeyBoard.key_one)) {
            cameraMode = CameraMode.camera_free;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        }
        if (ry.isKeyPressed(KeyBoard.key_two)) {
            cameraMode = CameraMode.camera_first_person;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        }
        if (ry.isKeyPressed(KeyBoard.key_three)) {
            cameraMode = CameraMode.camera_third_person;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        }
        if (ry.isKeyPressed(KeyBoard.key_four)) {
            cameraMode = CameraMode.camera_orbital;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
        }

        if (ry.isKeyPressed(KeyBoard.key_p)) {
            if (camera.projection == .camera_perspective) {
                // Create isometric view
                cameraMode = CameraMode.camera_third_person;
                // Note: The target distance is related to the render distance in the
                // orthographic projection
                camera.position = .{ .x = 0.0, .y = 2.0, .z = -100.0 };
                camera.target = .{ .x = 0.0, .y = 2.0, .z = 0.0 };
                camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
                camera.projection = CameraProjection.camera_orthographic;
                camera.fovy = 20.0; // near plane width in CAMERA_ORTHOGRAPHIC

                lib.cameraYaw(&camera, -135 * DEG2RAD, true);
                lib.cameraPitch(&camera, -45 * DEG2RAD, true, true, false);
            } else if (camera.projection == .camera_orthographic) {
                // Reset to default view
                cameraMode = CameraMode.camera_third_person;
                camera.position = .{ .x = 0.0, .y = 2.0, .z = 10.0 };
                camera.target = .{ .x = 0.0, .y = 2.0, .z = 0.0 };
                camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
                camera.projection = .camera_perspective;
                camera.fovy = 60.0;
            }
        }
        ry.updateCamera(&camera, cameraMode); // Update camera
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        ry.beginDrawing();

        ry.clearBackground(Color.ray_white);

        ry.beginMode3D(camera);

        ry.drawPlane(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, .{ .x = 32.0, .y = 32.0 }, Color.light_gray); // Draw ground
        ry.drawCube(.{ .x = -16.0, .y = 2.5, .z = 0.0 }, 1.0, 5.0, 32.0, Color.blue); // Draw a blue wall
        ry.drawCube(.{ .x = 16.0, .y = 2.0, .z = 0.0 }, 1.0, 5.0, 32.0, Color.lime); // Draw a green wall
        ry.drawCube(.{ .x = 0.0, .y = 2.0, .z = 16.0 }, 32.0, 5.0, 1.0, Color.gold); // Draw a yellow wall
        ry.drawCube(positions[2], 2.0, @floatFromInt(heights[2]), 2.0, colors[2]);

        for (0..MAX_COLUMNS) |i| {
            const height: f32 = @floatFromInt(heights[i]);
            ry.drawCube(positions[i], 2.0, height, 2.0, colors[i]);
            ry.drawCubeWires(positions[i], 2.0, height, 2.0, Color.maroon);
        }

        // Draw player cube
        if (cameraMode == .camera_third_person) {
            ry.drawCube(camera.target, 0.5, 0.5, 0.5, Color.purple);
            ry.drawCubeWires(camera.target, 0.5, 0.5, 0.5, Color.dark_purple);
        }

        ry.endMode3D();

        // Draw info boxes
        ry.drawRectangle(5, 5, 330, 100, ry.fade(Color.sky_blue, 0.0));
        ry.drawRectangleLines(5, 5, 330, 100, Color.blue);

        ry.drawText("Camera controls:", 15, 15, 10, Color.black);
        ry.drawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, Color.black);
        ry.drawText("- Look around: arrow keys or mouse", 15, 45, 10, Color.black);
        ry.drawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, Color.black);
        ry.drawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, Color.black);
        ry.drawText("- Camera projection key: P", 15, 90, 10, Color.black);

        ry.drawRectangle(600, 5, 195, 100, ry.fade(Color.sky_blue, 0.0));
        ry.drawRectangleLines(600, 5, 195, 100, Color.blue);

        ry.drawText("Camera status:", 610, 15, 10, Color.black);

        var case: [*:0]const u8 = undefined;
        switch (cameraMode) {
            .camera_free => case = "FREE",
            .camera_first_person => case = "FIRST_PERSON",
            .camera_third_person => case = "THIRD_PERSON",
            .camera_orbital => case = "ORBITAL",
            .camera_custom => case = "CUSTOM",
        }
        // std.debug.print("TypeInfo: {any}\n\nType: {any}\n", .{ @typeInfo(@TypeOf(case)), @TypeOf(case) });
        // ry.drawText("[NULL]", 610, 30, 10, Color.black);
        ry.drawText(ry.textFormat("- Mode: %s", .{case}), 610, 30, 10, Color.black);

        var projec: [*:0]const u8 = undefined;
        if (camera.projection == .camera_perspective) projec = "PERSPECTIVE" else if (camera.projection == .camera_orthographic) projec = "ORTHOGRAPHIC" else projec = "CUSTOM";

        ry.drawText(ry.textFormat("- Projection: %s", .{projec}), 610, 45, 10, .black);
        ry.drawText(ry.textFormat("- Position: (%06.3f, %06.3f, %06.3f)", .{ camera.position.x, camera.position.y, camera.position.z }), 610, 75, 10, .black);

        // DrawText(TextFormat("- Position: (%06.3f, %06.3f, %06.3f)",
        //                     camera.position.x, camera.position.y,
        //                     camera.position.z),
        //          610, 60, 10, BLACK);
        // DrawText(TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x,
        //                     camera.target.y, camera.target.z),
        //          610, 75, 10, BLACK);
        // DrawText(TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x,
        //                     camera.up.y, camera.up.z),
        //          610, 90, 10, BLACK);

        ry.endDrawing();
        //----------------------------------------------------------------------------------
    }
}
