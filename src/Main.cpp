#include <Siv3D.hpp> // Siv3D v0.6.16

void Main() {
  while (System::Update()) {
    Circle{Scene::Center(), 100}.draw(Palette::Red);
  }
}
