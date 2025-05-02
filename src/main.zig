const rl = @import("raylib");
const std = @import("std");

const screenWidth = 800.0;
const screenHeight = 450.0;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    const flags = rl.ConfigFlags{ .vsync_hint = false };
    rl.setWindowState(flags);

    var buffer: [100]u8 = undefined;
    const message = try std.fmt.bufPrintZ(&buffer, "Hello World", .{});

    var player = Player{
        .position = rl.Vector2{ .x = screenWidth / 5, .y = screenHeight / 2 },
        .acceleration = rl.Vector2{ .x = 0.0, .y = 0.0 },
        .velocity = rl.Vector2{ .x = 0.0, .y = 0.0 },
    };

    var pipe = Pipe{
        .x = screenWidth / 4.0,
    };
    var pipe2 = Pipe{
        .x = (screenWidth / 4.0) + pipe.x,
    };
    var pipe3 = Pipe{
        .x = (screenWidth / 4.0) + pipe2.x,
    };
    var pipe4 = Pipe{
        .x = (screenWidth / 4.0) + pipe3.x,
    };

    rl.initWindow(@as(i32, screenWidth), @as(i32, screenHeight), "Ziggy Bird");
    defer rl.closeWindow();

    rl.setTargetFPS(20);

    var delta = rl.getFrameTime();

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Controls
        if (rl.isKeyPressed(.space)) {
            player.acceleration.y = 20 * delta;
            player.velocity.y = -300;
        }

        // Update
        //----------------------------------------------------------------------------------
        delta = rl.getFrameTime();
        player.update_position(delta);
        pipe.update_position(delta);
        pipe2.update_position(delta);
        pipe3.update_position(delta);
        pipe4.update_position(delta);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        player.draw();

        pipe.draw();
        pipe2.draw();
        pipe3.draw();
        pipe4.draw();

        try show_fps();
        rl.drawText(message, 400, 225, 40, .red);

        rl.clearBackground(.white);
        //----------------------------------------------------------------------------------
    }
}

const Player = struct {
    position: rl.Vector2,
    acceleration: rl.Vector2,
    velocity: rl.Vector2,
    size: f32 = 20,

    pub fn update_position(self: *Player, delta: f32) void {
        self.acceleration.y += 20 * delta;

        self.velocity.x += self.acceleration.x;
        self.velocity.y += self.acceleration.y;

        self.position.x += self.velocity.x * delta;
        self.position.y += self.velocity.y * delta;

        self.position.y = rl.math.clamp(
            self.position.y,
            self.size / 2,
            screenHeight - self.size / 2,
        );
    }

    pub fn draw(self: *Player) void {
        rl.drawCircleV(self.position, 10, .sky_blue);
    }
};

const Pipe = struct {
    gap_size: f32 = 80,
    x: f32,
    top_pipe_y: f32 = screenHeight / 2,

    pub fn draw(self: *Pipe) void {
        rl.drawRectangleV(
            rl.Vector2{ .x = self.x, .y = 0 },
            rl.Vector2{ .x = 20, .y = self.top_pipe_y },
            .sky_blue,
        );

        rl.drawRectangleV(
            rl.Vector2{ .x = self.x, .y = self.top_pipe_y + self.gap_size },
            rl.Vector2{ .x = 20, .y = screenHeight - self.top_pipe_y },
            .sky_blue,
        );
    }

    pub fn update_position(self: *Pipe, delta: f32) void {
        self.x -= 200.0 * delta;
        if (self.x <= 0) {
            self.x = screenWidth;
            self.top_pipe_y = self.gap_size + std.crypto.random.float(f32) * ((screenHeight - 100) - self.gap_size);
        }
    }
};

pub fn show_fps() !void {
    var buffer: [10]u8 = undefined;
    const fps = try std.fmt.bufPrintZ(&buffer, "{d}", .{rl.getFPS()});
    rl.drawText(fps, 50, 50, 20, .red);
}
