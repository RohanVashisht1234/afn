const rl = @import("raylib");
const std = @import("std");

const MAX_COLUMNS = 20;

// This is an easy algorith I thought about to check if player is not hitting a wall/building.
inline fn check_boundaries(x1: f32, x2: f32, z1: f32, z2: f32, player_pos_x: f32, player_pos_z: f32) bool {
    return (player_pos_x > @min(x1, x2)) and (player_pos_x < @max(x1, x2)) and (player_pos_z > @min(z1, z2)) and (player_pos_z < @max(z1, z2));
}

const Bullet = struct {
    x: i32,
    y: i32,
    z: i32,
};

const bullets = struct {
    bullet_list: [5]Bullet,
    bullet_count_and_index: u8 = 0,
    bullet: Bullet,
    fn add_bullet() void {}
};
pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920;
    const screenHeight = 1080;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - 3d camera first person");
    defer rl.closeWindow(); // Close window and OpenGL context

    var camera = rl.Camera3D{
        .position = rl.Vector3.init(0, 1.7, 0),
        .target = rl.Vector3.init(1, 1, 1),
        .up = rl.Vector3.init(0, 1.8, 0),
        .fovy = 60,
        .projection = rl.CameraProjection.camera_perspective,
    };

    rl.disableCursor(); // Limit cursor to relative movement inside the window
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    // Main game loop
    // const road = rl.loadModel("./assets/road.glb");
    // const pistol = rl.loadModel("./assets/ok.glb");
    const building = rl.loadModel("./assets/building.glb");
    var old_pos = camera.position;
    const walk = rl.loadMusicStream("./assets/walk.mp3");
    // const gun = rl.loadModel("./assets/gun.glb");
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        camera.update(rl.CameraMode.camera_first_person);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        //rl.Color.init(188, 211, 247, 255)
        rl.clearBackground(rl.Color.sky_blue);

        {
            camera.begin();
            defer camera.end();
            // rl.drawModel(pistol, rl.Vector3.init(camera.position.x, camera.position.y-0.014, camera.position.z+0.01), 0.01, rl.Color.dark_gray);
            // rl.drawCube(rl.Vector3.init(0, 0, 0), 100000, 0.5, 100000, rl.Color.dark_brown);
            // for (0..100) |i| {
            //     rl.drawModel(
            //         road,
            //         rl.Vector3.init(0.0, 1.0, @as(f32, @floatFromInt(i)) * 31),
            //         0.05,
            //         rl.Color.gray,
            //     );
            // }
            if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
                rl.updateMusicStream(walk);
                rl.playMusicStream(walk);
            }
            if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {}
            rl.drawModel(
                building,
                rl.Vector3.init(0.0, 0.1, 0.0),
                1,
                rl.Color.ray_white,
            );
            if (camera.position.x > 33) {
                camera.position.x = 33;
            }
            if (camera.position.x < -33) {
                camera.position.x = -33;
            }
            if (camera.position.z < -34) {
                camera.position.z = -34;
            }
            if (camera.position.z > 32) {
                camera.position.z = 32;
            }
            if (camera.position.z < -5.8 and camera.position.z > -15.6 and camera.position.x > 4 and camera.position.x < 14) {
                camera.position = old_pos;
            }
            // x: 14.5, z: 8.2,
            // x: 4.5, z:25.5
            if (check_boundaries(14.5, 4.5, 8.2, 25.5, camera.position.x, camera.position.z) or check_boundaries(-4.5, -14.4, 8.2, 25.3, camera.position.x, camera.position.z) or check_boundaries(16.5, 26.5, -15.9, -5.8, camera.position.x, camera.position.z) or check_boundaries(16.5, 26.5, -17.7, -27.7, camera.position.x, camera.position.z) or check_boundaries(-12.2, -14.0, -12.5, -11.4, camera.position.x, camera.position.z) or check_boundaries(14.5, 4.6, -17.8, -27.7, camera.position.x, camera.position.z) or check_boundaries(-26.6, -16.6, 8.1, 25.3, camera.position.x, camera.position.z) or check_boundaries(16.6, 26.5, 25.3, 15.3, camera.position.x, camera.position.z) or check_boundaries(-18.9, -26.6, -17.7, -8.15, camera.position.x, camera.position.z) or check_boundaries(-6.9, -26.6, -17.7, -27.7, camera.position.x, camera.position.z) or check_boundaries(22.6, 20.7, 13.7, 12.6, camera.position.x, camera.position.z)) {
                camera.position = old_pos;
            }
            old_pos = camera.position;

            // rl.drawModel(buildings, rl.Vector3.init(40, 1.0, 40.0), 1, rl.Color.gray);
        }
        //----------------------------------------------------------------------------------
        rl.drawCircle(screenWidth / 2, screenHeight / 2, 2, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2 - 35, screenHeight / 2, 25, 2), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2 + 10, screenHeight / 2, 25, 2), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2, screenHeight / 2 + 10, 2, 25), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2, screenHeight / 2 - 35, 2, 25), 50, 1, rl.Color.light_gray);
        var buf: [20]u8 = undefined;
        rl.drawText(std.fmt.bufPrintZ(&buf, "x : {d}", .{camera.position.x}) catch @panic("message: []const u8"), 20, 20, 20, rl.Color.red);
        rl.drawText(std.fmt.bufPrintZ(&buf, "y : {d}", .{camera.position.y}) catch @panic("message: []const u8"), 20, 40, 20, rl.Color.red);
        rl.drawText(std.fmt.bufPrintZ(&buf, "z : {d}", .{camera.position.z}) catch @panic("message: []const u8"), 20, 60, 20, rl.Color.red);
    }
}
