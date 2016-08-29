module Entity.UI;
static import AOD;
static import Data;

class HUD : AOD.Entity {
public:
  this() {
    super(Data.Layer.UI);
    Set_Static_Pos(true);
    Set_Position(AOD.R_Window_Width/2, 18/2);
    Set_Sprite(Data.Image.HUD);
  }
  override void Update() {

  }
}
