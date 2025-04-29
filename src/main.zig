const rl = @import("raylib");
const std = @import("std");
const raygui = @import("raygui");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    const flags = rl.ConfigFlags{ .vsync_hint = true };
    rl.setWindowState(flags);

    var player = Player{
        .position = rl.Vector2{ .x = 100, .y = 200 },
        .acceleration = rl.Vector2{ .x = 0.0, .y = 0.0 },
        .velocity = rl.Vector2{ .x = 0.0, .y = 0.0 },
    };

    var pipe = Pipe{
        .gap_size = 100,
        .x = 300,
        .top_pipe_y = 225,
    };
    var pipe2 = Pipe{
        .gap_size = 100,
        .x = 600,
        .top_pipe_y = 225,
    };
    var pipe3 = Pipe{
        .gap_size = 100,
        .x = 800,
        .top_pipe_y = 225,
    };

    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var delta = rl.getFrameTime();

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Controls
        if (rl.isKeyPressed(.space)) {
            player.acceleration.y = 0.9;
            player.velocity.y = -300;
        }

        // Update
        //----------------------------------------------------------------------------------
        delta = rl.getFrameTime();
        player.update_position(delta);
        pipe.update_position(delta);
        pipe2.update_position(delta);
        pipe3.update_position(delta);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        player.draw();

        pipe.draw();
        pipe2.draw();
        pipe3.draw();

        try show_fps();
        rl.clearBackground(.white);
        //----------------------------------------------------------------------------------
    }
}

const Player = struct {
    position: rl.Vector2,
    acceleration: rl.Vector2,
    velocity: rl.Vector2,

    pub fn update_position(self: *Player, delta: f32) void {
        self.acceleration.y += 0.7;

        self.velocity.x += self.acceleration.x;
        self.velocity.y += self.acceleration.y;

        self.position.x += self.velocity.x * delta;
        self.position.y += self.velocity.y * delta;

        self.position.y = rl.math.clamp(self.position.y, 20, 430);
    }

    pub fn draw(self: *Player) void {
        rl.drawCircleV(self.position, 20, .sky_blue);
    }
};

const Pipe = struct {
    gap_size: f32,
    x: f32,
    top_pipe_y: f32,

    pub fn draw(self: *Pipe) void {
        rl.drawRectangleV(
            rl.Vector2{ .x = self.x, .y = 0 },
            rl.Vector2{ .x = 20, .y = self.top_pipe_y },
            .sky_blue,
        );

        rl.drawRectangleV(
            rl.Vector2{ .x = self.x, .y = self.top_pipe_y + self.gap_size },
            rl.Vector2{ .x = 20, .y = 450 - self.top_pipe_y },
            .sky_blue,
        );
    }

    pub fn update_position(self: *Pipe, delta: f32) void {
        self.x -= 200.0 * delta;
        if (self.x <= 0) {
            self.x = 800;
            self.top_pipe_y = 100 + std.crypto.random.float(f32) * (400 - 100);
        }
    }
};

pub fn show_fps() !void {
    var buffer: [10]u8 = undefined;
    const fps = try std.fmt.bufPrintZ(&buffer, "{d}", .{rl.getFPS()});
    rl.drawText(fps, 50, 50, 20, .red);
}
