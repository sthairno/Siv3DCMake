#include <Siv3D.hpp> // Siv3D v0.6.16

namespace
{
constexpr Size SceneSize{800, 300};
constexpr double GroundY = 250.0;
constexpr double DinoX = 80.0;
constexpr double DinoScale = 0.55;
constexpr double Gravity = 2000.0;
constexpr double JumpVelocity = -720.0;
constexpr double JumpHoldGravityScale = 0.55;
constexpr double JumpCutFactor = 0.42;
constexpr double InitialScrollSpeed = 420.0;
constexpr double MaxScrollSpeed = 900.0;
constexpr double SpeedAccel = 18.0;
constexpr double MinSpawnGap = 520.0;
constexpr double MaxSpawnGap = 980.0;
constexpr double LongSpawnGapMin = 1100.0;
constexpr double LongSpawnGapMax = 1600.0;
constexpr double LongSpawnChance = 0.14;
constexpr double ClusterSpacingMin = 28.0;
constexpr double ClusterSpacingMax = 52.0;
constexpr SizeF DinoHitboxSize{34, 38};
constexpr Vec2 DinoHitboxOffset{2, 6};

enum class GameState
{
    Waiting,
    Playing,
    GameOver
};

struct Obstacle
{
    RectF hitbox;
    double width;
    double height;
};

struct Game
{
    GameState state = GameState::Waiting;
    double dinoY = 0.0;
    double velocityY = 0.0;
    bool onGround = true;
    double scrollSpeed = InitialScrollSpeed;
    double elapsed = 0.0;
    int32 score = 0;
    double groundOffset = 0.0;
    double distanceSinceLastSpawn = 0.0;
    double nextSpawnGap = 0.0;
    Array<Obstacle> obstacles;
};

constexpr double GroundDinoCenterY()
{
    return GroundY - 42.0 * DinoScale;
}

RectF DinoHitbox(const Vec2 &center)
{
    return RectF{center.x + DinoHitboxOffset.x - DinoHitboxSize.x * 0.5,
                 center.y + DinoHitboxOffset.y - DinoHitboxSize.y * 0.5, DinoHitboxSize.x, DinoHitboxSize.y};
}

void DrawGround(double groundOffset)
{
    const ColorF lineColor{0.2};
    Line{0, GroundY, SceneSize.x, GroundY}.draw(2, lineColor);

    constexpr double dashSpacing = 24.0;
    for (double x = -dashSpacing + Math::Fmod(groundOffset, dashSpacing); x < SceneSize.x; x += dashSpacing)
    {
        RectF{x, GroundY - 12, 12, 2}.draw(lineColor);
    }
}

void DrawCactus(const Obstacle &obstacle)
{
    const ColorF color{0.2};
    const RectF body{obstacle.hitbox.x, obstacle.hitbox.y, obstacle.width * 0.45, obstacle.height};
    body.draw(color);

    const double armW = obstacle.width * 0.35;
    const double armH = obstacle.height * 0.35;
    RectF{body.x - armW * 0.6, body.y + obstacle.height * 0.25, armW, armH}.draw(color);
    RectF{body.x + body.w - armW * 0.4, body.y + obstacle.height * 0.45, armW, armH}.draw(color);
}

void DrawDino(const Texture &dino, const Vec2 &center, bool onGround)
{
    const auto sprite = dino.scaled(DinoScale).mirrored();
    if (!onGround)
    {
        sprite.rotated(-15_deg).drawAt(center);
    }
    else
    {
        sprite.drawAt(center);
    }
}

void ResetGame(Game &game)
{
    game = Game{};
    game.dinoY = GroundDinoCenterY();
    game.nextSpawnGap = Random(700.0, 1100.0);
}

double NextSpawnGap(const Game &game)
{
    const double speedFactor = Clamp(game.scrollSpeed / InitialScrollSpeed, 1.0, 1.6);

    if (RandomBool(LongSpawnChance))
    {
        return Random(LongSpawnGapMin, LongSpawnGapMax) * speedFactor;
    }

    return Random(MinSpawnGap, MaxSpawnGap) * speedFactor;
}

void AddCactus(Game &game, double x, bool large)
{
    const double width = large ? 34.0 : 22.0;
    const double height = large ? 58.0 : 42.0;
    const RectF hitbox{x, GroundY - height + 8, width * 0.7, height - 8};
    game.obstacles << Obstacle{hitbox, width, height};
}

void SpawnObstaclePattern(Game &game)
{
    const int32 pattern = Random(0, 99);

    if (pattern < 38)
    {
        AddCactus(game, SceneSize.x, false);
    }
    else if (pattern < 63)
    {
        AddCactus(game, SceneSize.x, true);
    }
    else if (pattern < 83)
    {
        const double spacing = Random(ClusterSpacingMin, ClusterSpacingMax);
        AddCactus(game, SceneSize.x, false);
        AddCactus(game, SceneSize.x + spacing, false);
    }
    else if (pattern < 93)
    {
        const double spacing = Random(ClusterSpacingMin, ClusterSpacingMax);
        AddCactus(game, SceneSize.x, false);
        AddCactus(game, SceneSize.x + spacing, true);
    }
    else
    {
        const double spacing1 = Random(ClusterSpacingMin, ClusterSpacingMax);
        const double spacing2 = Random(ClusterSpacingMin, ClusterSpacingMax);
        AddCactus(game, SceneSize.x, false);
        AddCactus(game, SceneSize.x + spacing1, false);
        AddCactus(game, SceneSize.x + spacing1 + spacing2, false);
    }
}

bool JumpDown()
{
    return KeySpace.down() || KeyUp.down() || MouseL.down();
}

bool JumpUp()
{
    return KeySpace.up() || KeyUp.up() || MouseL.up();
}

bool JumpHeld()
{
    return KeySpace.pressed() || KeyUp.pressed() || MouseL.pressed();
}
} // namespace

void Main()
{
    Window::Resize(SceneSize);
    Window::SetTitle(U"T-Rex Runner");
    Scene::SetBackground(ColorF{1.0});
    Scene::SetLetterbox(ColorF{1.0});

    const Texture dino{U"🦖"_emoji};
    const Font font{FontMethod::MSDF, 24, Typeface::Bold};
    const Font uiFont{FontMethod::MSDF, 20};

    Game game;
    ResetGame(game);

    while (System::Update())
    {
        const double dt = Scene::DeltaTime();
        const Vec2 dinoCenter{DinoX, game.dinoY};
        const bool jumpDown = JumpDown();

        if (game.state == GameState::Waiting && jumpDown)
        {
            game.state = GameState::Playing;
        }
        else if (game.state == GameState::GameOver && jumpDown)
        {
            ResetGame(game);
            game.state = GameState::Playing;
        }

        if (game.state == GameState::Playing)
        {
            if (jumpDown && game.onGround)
            {
                game.velocityY = JumpVelocity;
                game.onGround = false;
            }

            if (!game.onGround && game.velocityY < 0 && JumpUp())
            {
                game.velocityY *= JumpCutFactor;
            }

            const double gravity =
                (!game.onGround && game.velocityY < 0 && JumpHeld()) ? Gravity * JumpHoldGravityScale : Gravity;
            game.velocityY += gravity * dt;
            game.dinoY += game.velocityY * dt;

            if (game.dinoY >= GroundDinoCenterY())
            {
                game.dinoY = GroundDinoCenterY();
                game.velocityY = 0.0;
                game.onGround = true;
            }

            game.elapsed += dt;
            game.scrollSpeed = Min(InitialScrollSpeed + game.elapsed * SpeedAccel, MaxScrollSpeed);
            game.score += static_cast<int32>(game.scrollSpeed * dt * 0.01);
            game.groundOffset += game.scrollSpeed * dt;
            game.distanceSinceLastSpawn += game.scrollSpeed * dt;

            for (auto &obstacle : game.obstacles)
            {
                obstacle.hitbox.x -= game.scrollSpeed * dt;
            }
            game.obstacles.remove_if(
                [](const Obstacle &obstacle) { return (obstacle.hitbox.x + obstacle.hitbox.w < 0); });

            if (game.distanceSinceLastSpawn >= game.nextSpawnGap)
            {
                SpawnObstaclePattern(game);
                game.distanceSinceLastSpawn = 0.0;
                game.nextSpawnGap = NextSpawnGap(game);
            }

            const RectF playerHitbox = DinoHitbox(dinoCenter);
            for (const auto &obstacle : game.obstacles)
            {
                if (playerHitbox.intersects(obstacle.hitbox))
                {
                    game.state = GameState::GameOver;
                    break;
                }
            }
        }

        DrawGround(game.groundOffset);

        for (const auto &obstacle : game.obstacles)
        {
            DrawCactus(obstacle);
        }

        DrawDino(dino, dinoCenter, game.onGround);

        font(U"{:05}"_fmt(game.score)).draw(SceneSize.x - 120, 16, ColorF{0.2});

        if (game.state == GameState::Waiting)
        {
            uiFont(U"Press Space to start").drawAt(SceneSize.x * 0.5, 90, ColorF{0.35});
        }
        else if (game.state == GameState::GameOver)
        {
            font(U"GAME OVER").drawAt(SceneSize.x * 0.5, 90, ColorF{0.2});
            uiFont(U"Press Space to restart").drawAt(SceneSize.x * 0.5, 125, ColorF{0.35});
        }
    }
}
