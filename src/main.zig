const rl = @import("raylib");
const std = @import("std");

const allocator_c = std.heap.c_allocator;

const MAX_COLUMNS = 20;

const URL = "http://game-backend-vr99.onrender.com/";

const user_name = "rohan";
const user_name2 = "paras";

// This is an easy algorith I thought about to check if player is not hitting a wall/building.
inline fn check_boundaries(x1: f32, x2: f32, z1: f32, z2: f32, player_pos_x: f32, player_pos_z: f32) bool {
    return (player_pos_x > @min(x1, x2)) and (player_pos_x < @max(x1, x2)) and (player_pos_z > @min(z1, z2)) and (player_pos_z < @max(z1, z2));
}

const Bullet = struct {
    position: rl.Vector3,
    direction: rl.Vector3,
    active: bool,
};

var user2_location = [2]f32{ 0, 0 };
var user_location = [2]f32{ 0, 0 };

pub fn main() !void {
    std.debug.print("OK", .{});
    var bullets: [50]Bullet = undefined;
    var bulletIndex: usize = 0;
    const screenWidth = 720;
    const screenHeight = 420;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - 3d camera first person");
    rl.initAudioDevice();
    defer rl.closeWindow();
    std.debug.print("\nOK", .{});

    var camera = rl.Camera3D{
        .position = rl.Vector3.init(0, 1.7, 0),
        .target = rl.Vector3.init(1, 1, 1),
        .up = rl.Vector3.init(0, 1.8, 0),
        .fovy = 60,
        .projection = rl.CameraProjection.camera_perspective,
    };

    rl.disableCursor();
    rl.setTargetFPS(60);
    const building = rl.loadModel("./assets/building.glb");
    var old_pos = camera.position;
    const walk = rl.loadMusicStream("./assets/walk.mp3");
    const normal = rl.loadMusicStream("./assets/normal.mp3");
    const shoot = rl.loadMusicStream("./assets/shoot.mp3");
    rl.playMusicStream(normal);

    const t1 = try std.Thread.spawn(.{}, set, .{});
    const t2 = try std.Thread.spawn(.{}, get, .{});

    while (!rl.windowShouldClose()) {
        user_location = [2]f32{ camera.position.x, camera.position.y };

        camera.update(rl.CameraMode.camera_first_person);
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.sky_blue);

        {
            camera.begin();
            defer camera.end();
            for (&bullets) |*bul| {
                if (bul.active) {
                    bul.position = rl.Vector3.add(bul.position, rl.Vector3.scale(bul.direction, 4)); // Move forward
                    // Deactivate bullets that go out of range
                    if (rl.Vector3.length(bul.position) > 100.0) {
                        bul.active = false;
                    }
                }
            }
            for (&bullets) |bul| {
                if (bul.active) {
                    rl.drawCylinder(bul.position, 0.1, 0.1, 0.1, 100, rl.Color.gold); // Draw the bullet
                }
            }
            rl.drawCube(rl.Vector3.init(user2_location[0], 1, user2_location[1]), 1, 1, 1, rl.Color.red);
            if (rl.isKeyPressed(rl.KeyboardKey.key_w)) {
                rl.playMusicStream(walk);
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
                rl.updateMusicStream(walk);
            }
            if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
                rl.playMusicStream(shoot);
                var currentBullet = &bullets[bulletIndex];
                currentBullet.position = camera.position;
                const forward = rl.Vector3.subtract(camera.target, camera.position);
                currentBullet.direction = rl.Vector3.normalize(forward);
                currentBullet.active = true;
                bulletIndex = (bulletIndex + 1) % 50; // Cycle through the bullet array
            }
            if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left)) {
                rl.updateMusicStream(shoot);
            }
            rl.updateMusicStream(normal);

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
            if (check_boundaries(14.5, 4.5, 8.2, 25.5, camera.position.x, camera.position.z) or check_boundaries(-4.5, -14.4, 8.2, 25.3, camera.position.x, camera.position.z) or check_boundaries(16.5, 26.5, -15.9, -5.8, camera.position.x, camera.position.z) or check_boundaries(16.5, 26.5, -17.7, -27.7, camera.position.x, camera.position.z) or check_boundaries(-12.2, -14.0, -12.5, -11.4, camera.position.x, camera.position.z) or check_boundaries(14.5, 4.6, -17.8, -27.7, camera.position.x, camera.position.z) or check_boundaries(-26.6, -16.6, 8.1, 25.3, camera.position.x, camera.position.z) or check_boundaries(16.6, 26.5, 25.3, 15.3, camera.position.x, camera.position.z) or check_boundaries(-18.9, -26.6, -17.7, -8.15, camera.position.x, camera.position.z) or check_boundaries(-6.9, -26.6, -17.7, -27.7, camera.position.x, camera.position.z) or check_boundaries(22.6, 20.7, 13.7, 12.6, camera.position.x, camera.position.z)) {
                camera.position = old_pos;
            }
            old_pos = camera.position;
        }
        rl.drawCircle(screenWidth / 2, screenHeight / 2, 2, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2 - 35, screenHeight / 2, 25, 2), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2 + 10, screenHeight / 2, 25, 2), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2, screenHeight / 2 + 10, 2, 25), 50, 1, rl.Color.light_gray);
        rl.drawRectangleRounded(rl.Rectangle.init(screenWidth / 2, screenHeight / 2 - 35, 2, 25), 50, 1, rl.Color.light_gray);

        //  var buf: [20]u8 = undefined;
        //  rl.drawText(std.fmt.bufPrintZ(&buf, "x : {d}", .{camera.position.x}) catch @panic("message: []const u8"), 20, 20, 20, rl.Color.red);
        //  rl.drawText(std.fmt.bufPrintZ(&buf, "y : {d}", .{camera.position.y}) catch @panic("message: []const u8"), 20, 40, 20, rl.Color.red);
        //  rl.drawText(std.fmt.bufPrintZ(&buf, "z : {d}", .{camera.position.z}) catch @panic("message: []const u8"), 20, 60, 20, rl.Color.red);
    }
    t1.join();
    t2.join();
}

pub fn fetchNormal(allocator: std.mem.Allocator, url: []const u8) []const u8 {
    var charBuffer = std.ArrayList(u8).init(allocator);
    errdefer charBuffer.deinit();
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();
    const fetchOptions = std.http.Client.FetchOptions{
        .location = std.http.Client.FetchOptions.Location{
            .url = url,
        },
        .method = .GET,
        .response_storage = .{ .dynamic = &charBuffer },
    };
    _ = client.fetch(fetchOptions) catch @panic("Internet issue.");
    return charBuffer.toOwnedSlice() catch @panic("Can't convert buffer to string");
}

fn set() !void {
    while (true) {
        var buf: [500]u8 = undefined;
        const resultant = try std.fmt.bufPrintZ(&buf, URL ++ "set/" ++ user_name ++ "/?{d}:{d}", .{ user_location[0], user_location[1] });
        // std.debug.print("{s}", .{resultant});
        _ = fetchNormal(allocator_c, resultant); // send location
    }
    return;
}

fn get() void {
    while (true) {
        const result = fetchNormal(allocator_c, URL ++ "get/" ++ user_name2 ++ "/"); // get location
        var iter = std.mem.splitScalar(u8, result, ':');
        const user_location_x: f32 = std.fmt.parseFloat(f32, iter.next().?) catch 0;
        const user_location_z: f32 = std.fmt.parseFloat(f32, iter.next().?) catch 0;
        user2_location = [2]f32{ user_location_x, user_location_z };
    }
}
