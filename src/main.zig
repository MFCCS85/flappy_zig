const rl = @import("raylib");
const std = @import("std");
const raygui = @import("raygui");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    var player = Player{
        .position = rl.Vector2{ .x = 250, .y = 200 },
        .acceleration = rl.Vector2{ .x = 0.0, .y = 0.0 },
        .velocity = rl.Vector2{ .x = 0.0, .y = 0.0 },
    };

    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var delta = rl.getFrameTime();

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Controls
        if (rl.isKeyPressed(.space)) {
            player.acceleration.y = 0;
            player.velocity.y = -150;
        }

        // Update
        //----------------------------------------------------------------------------------
        delta = rl.getFrameTime();
        player.update_position(delta);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        player.draw();

        rl.clearBackground(.white);
        //----------------------------------------------------------------------------------
    }
}

const Player = struct {
    position: rl.Vector2,
    acceleration: rl.Vector2,
    velocity: rl.Vector2,

    pub fn update_position(self: *Player, delta: f32) void {
        self.acceleration.y += 800 * delta;

        self.velocity.x += self.acceleration.x * delta;
        self.velocity.y += self.acceleration.y * delta;

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
};
