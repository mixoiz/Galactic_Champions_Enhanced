package battle
{
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import players.AIPlayer;
   import players.Player;
   import players.aliens.Alien;
   import players.effects.Effect;
   import players.items.Item;
   import players.skills.Skill;
   import tutorial.TutorialManager;
   import ui.HUDManager;
   import ui.battle.BattleHUD;
   import view.LayerFactory;
   
   public class Battle
   {
      
      public static const STATE_IDLE:String = "idle";
      
      public static const STATE_INTRO:String = "intro";
      
      public static const STATE_BEGIN_TURN:String = "begin_turn";
      
      public static const STATE_DEFEATED_ALIEN:String = "defeated_alien";
      
      public static const STATE_UPDATE_EFFECTS_1:String = "update_effects_1";
      
      public static const STATE_UPDATE_EFFECTS_2:String = "update_effects_2";
      
      public static const STATE_ACTION_MENU:String = "actions_menu";
      
      public static const STATE_ITEM:String = "item";
      
      public static const STATE_UPDATE_ITEM_EFFECTS:String = "update_item_effects";
      
      public static const STATE_DEFENSE:String = "defense";
      
      public static const STATE_ATTACK:String = "attack";
      
      public static const STATE_SWAP:String = "swap";
      
      public static const STATE_UPDATE_EFFECTS_3:String = "update_effects_3";
      
      public static const STATE_UPDATE_EFFECTS_4:String = "update_effects_4";
      
      public static const STATE_DEFEATED_ALIEN_2:String = "defeated_alien_2";
      
      public static const STATE_END_TURN:String = "end_turn";
      
      public static const STATE_OUTRO:String = "outro";
      
      private var _initialized:Boolean;
      
      private var _player1:Player;
      
      private var _player2:AIPlayer;
      
      private var _battleGame:BattleGame;
      
      private var _player1Aliens:Vector.<Alien>;
      
      private var _player2Aliens:Vector.<Alien>;
      
      private var _activePlayer:int;
      
      private var _player1AlienIndex:int;
      
      private var _player2AlienIndex:int;
      
      private var _xpRewardBonus:int;
      
      private var _goldRewardBonus:int;
      
      private var _states:Dictionary;
      
      private var _previousState:String;
      
      private var _currentState:String;
      
      private var _actionsLeft:int;
      
      private var _battleHUD:BattleHUD;
      
      private var _background:MovieClip;
      
      private var cont:int = 0;
      
      private var _swapTargetPlayer:int;
      
      private var _swapTargetAlien:int;
      
      private var _newEffectsToProcess:Vector.<Effect>;
      
      private var _itemsUsed:String;
      
      private var _itemUsed:Item;
      
      private var _itemTargetIndex:int;
      
      private var _skillUsed:Skill;
      
      private var _damageDone:int;
      
      public function Battle(param1:Player, param2:BattleGame)
      {
         super();
         this._initialized = false;
         this._player1 = param1;
         this._battleGame = param2;
      }
      
      private function CreateBattleStates() : void
      {
         this._states = new Dictionary();
         this._states[STATE_IDLE] = new BattleState_Idle(this);
         this._states[STATE_INTRO] = new BattleState_Intro(this);
         this._states[STATE_BEGIN_TURN] = new BattleState_BeginTurn(this);
         this._states[STATE_DEFEATED_ALIEN] = new BattleState_DefeatedAlien(this);
         this._states[STATE_UPDATE_EFFECTS_1] = new BattleState_UpdateEffects(this,STATE_UPDATE_EFFECTS_1);
         this._states[STATE_UPDATE_EFFECTS_2] = new BattleState_UpdateEffects(this,STATE_UPDATE_EFFECTS_2);
         this._states[STATE_ACTION_MENU] = new BattleState_ActionMenu(this);
         this._states[STATE_ITEM] = new BattleState_Item(this);
         this._states[STATE_UPDATE_ITEM_EFFECTS] = new BattleState_UpdateItemEffects(this);
         this._states[STATE_DEFENSE] = new BattleState_Defense(this);
         this._states[STATE_ATTACK] = new BattleState_Attack(this);
         this._states[STATE_SWAP] = new BattleState_Swap(this);
         this._states[STATE_UPDATE_EFFECTS_3] = new BattleState_UpdateEffects(this,STATE_UPDATE_EFFECTS_3);
         this._states[STATE_UPDATE_EFFECTS_4] = new BattleState_UpdateEffects(this,STATE_UPDATE_EFFECTS_4);
         this._states[STATE_DEFEATED_ALIEN_2] = new BattleState_DefeatedAlien(this);
         this._states[STATE_END_TURN] = new BattleState_EndTurn(this);
         this._states[STATE_OUTRO] = new BattleState_Outro(this);
      }
      
      private function DestroyStates() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this._states)
         {
            BattleState(_loc1_).Destroy();
         }
         this._states = null;
      }
      
      public function GetBattleBackgroundToLoadID() : String
      {
         return this._battleGame.getBattleBackgroundID();
      }
      
      public function GetBattleAliensToLoadIds() : String
      {
         var _loc1_:String = "";
         _loc1_ += this._player1.getAliensChosenIds();
         _loc1_ += "," + this._battleGame.getAIAliensIdsForBattle();
         return _loc1_.toLowerCase();
      }
      
      public function PrepareBattle() : void
      {
         this.CreateBackground();
         this.SetUpPlayer1();
         this.SetUpPlayer2();
         this._currentState = "";
         this._xpRewardBonus = 100;
         this._goldRewardBonus = 100;
         this._activePlayer = 1;
         this._player1AlienIndex = this.SearchFirstAlien(this._player1Aliens);
         this._player2AlienIndex = this.SearchFirstAlien(this._player2Aliens);
         this.CreateBattleStates();
         this.CreateBattleHUD();
         this._initialized = true;
      }
      
      public function BeginBattle() : void
      {
         this.SetState(STATE_INTRO);
      }
      
      private function CreateBattleHUD() : void
      {
         this._battleHUD = new BattleHUD();
         this._battleHUD.Initialize(this);
      }
      
      private function CreateBackground() : void
      {
         this._background = ExternalLoader.Instance.GetNewInstance("BackgroundAsset",this._battleGame.getBattleBackgroundID() + ".swf") as MovieClip;
         LayerFactory.Instance.GetLayer(LayerFactory.BACKGROUND).addChildAt(this._background,0);
      }
      
      public function SearchFirstAlien(param1:Vector.<Alien>) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc3_ = 0;
         _loc2_ = -1;
         while(_loc3_ < param1.length && _loc2_ == -1)
         {
            if(param1[_loc3_].currentHp > 0)
            {
               _loc2_ = _loc3_;
            }
            else
            {
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      private function SetUpPlayer1() : void
      {
         var _loc1_:Alien = null;
         this._player1Aliens = this._player1.CreateAliensForBattle();
         for each(_loc1_ in this._player1Aliens)
         {
            _loc1_.currentHp = _loc1_.hp;
            _loc1_.currentMp = _loc1_.mp;
         }
      }
      
      private function SetUpPlayer2() : void
      {
         var _loc1_:Alien = null;
         this._player2 = new AIPlayer(this);
         this._player2Aliens = this._player2.CreateAliensForBattle(this._battleGame.getAIAlienInfosForBattle());
         this._player2.CreateInventory(this._battleGame.getAIInventoryData());
         for each(_loc1_ in this._player2Aliens)
         {
            _loc1_.currentHp = _loc1_.hp;
            _loc1_.currentMp = _loc1_.mp;
         }
      }
      
      public function ClearItemsUsedList() : void
      {
         this._itemsUsed = "";
      }
      
      public function CanItemBeUsed(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         switch(param1)
         {
            case Item.ITEM_PURIFY:
               _loc2_ = this.isAnyActivePlayerAlienAffectedByEnemyEffect();
               break;
            case Item.ITEM_INVULNERABILITY:
               _loc2_ = this._itemsUsed.indexOf(param1) == -1;
               break;
            case Item.ITEM_BONUS_GOLD:
               _loc2_ = this._goldRewardBonus == 100;
               break;
            case Item.ITEM_BONUS_XP:
               _loc2_ = this._xpRewardBonus == 100;
               break;
            case Item.ITEM_SWITCH:
               _loc2_ = this.doesActivePlayerHaveMoreThan1AlienLeft();
               break;
            case Item.ITEM_SWITCH_E:
               _loc2_ = this.doesActivePlayerEnemyHaveMoreThan1AlienLeft();
               break;
            case Item.ITEM_REVIVE:
               _loc2_ = this.wasAnyActivePlayerAlienDefeated();
               break;
            case Item.ITEM_DOUBLE_ACTION:
               _loc2_ = this._itemsUsed.indexOf(param1) == -1;
               break;
            default:
               _loc2_ = true;
         }
         return _loc2_;
      }
      
      private function isAnyActivePlayerAlienAffectedByEnemyEffect() : Boolean
      {
         var _loc1_:Vector.<Alien> = null;
         var _loc2_:Alien = null;
         var _loc3_:Boolean = false;
         _loc3_ = false;
         if(this._activePlayer == 1)
         {
            _loc1_ = this._player1Aliens;
         }
         else
         {
            _loc1_ = this._player2Aliens;
         }
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_.isAffectedByEnemyStateEffect())
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      private function wasAnyActivePlayerAlienDefeated() : Boolean
      {
         var _loc1_:Vector.<Alien> = null;
         var _loc2_:Alien = null;
         var _loc3_:Boolean = false;
         _loc3_ = false;
         if(this._activePlayer == 1)
         {
            _loc1_ = this._player1Aliens;
         }
         else
         {
            _loc1_ = this._player2Aliens;
         }
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_.currentHp <= 0)
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      private function doesActivePlayerHaveMoreThan1AlienLeft() : Boolean
      {
         var _loc1_:Vector.<Alien> = null;
         var _loc2_:Alien = null;
         var _loc3_:int = 0;
         _loc3_ = 0;
         if(this._activePlayer == 1)
         {
            _loc1_ = this._player1Aliens;
         }
         else
         {
            _loc1_ = this._player2Aliens;
         }
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_.currentHp > 0)
            {
               _loc3_++;
            }
         }
         return _loc3_ > 1;
      }
      
      private function doesActivePlayerEnemyHaveMoreThan1AlienLeft() : Boolean
      {
         var _loc1_:Vector.<Alien> = null;
         var _loc2_:Alien = null;
         var _loc3_:int = 0;
         _loc3_ = 0;
         if(this._activePlayer == 1)
         {
            _loc1_ = this._player2Aliens;
         }
         else
         {
            _loc1_ = this._player1Aliens;
         }
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_.currentHp > 0)
            {
               _loc3_++;
            }
         }
         return _loc3_ > 1;
      }
      
      public function SetState(param1:String) : void
      {
         var _loc2_:BattleState = null;
         var _loc3_:BattleState = null;
         if(param1 != this._currentState)
         {
            _loc2_ = this._states[param1];
            _loc3_ = this._states[this._currentState];
            if(_loc3_ != null)
            {
               _loc3_.Leave();
            }
            this._previousState = this._currentState;
            this._currentState = param1;
            if(_loc2_ != null)
            {
               _loc2_.Enter();
            }
         }
      }
      
      public function Update(param1:int) : void
      {
         this._states[this._currentState].Update(param1);
         this._player1Aliens[this._player1AlienIndex].Update(param1);
         this._player2Aliens[this._player2AlienIndex].Update(param1);
      }
      
      public function GetPlayerAlien(param1:int) : Alien
      {
         if(param1 == 1)
         {
            return this._player1Aliens[this._player1AlienIndex];
         }
         return this._player2Aliens[this._player2AlienIndex];
      }
      
      public function GetPlayerAlienByID(param1:int, param2:String) : Alien
      {
         var _loc3_:Vector.<Alien> = null;
         var _loc4_:Alien = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         _loc4_ = null;
         _loc5_ = true;
         _loc6_ = 0;
         if(param1 == 1)
         {
            _loc3_ = this._player1Aliens;
         }
         else
         {
            _loc3_ = this._player2Aliens;
         }
         while(_loc5_ && _loc6_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc6_];
            if(_loc4_.id == param2)
            {
               _loc5_ = false;
            }
            else
            {
               _loc6_++;
            }
         }
         return _loc4_;
      }
      
      public function GetAlienEffectsByIndex(param1:int, param2:int) : Vector.<Effect>
      {
         if(param1 == 1)
         {
            return this._player1Aliens[param2].currentEffects;
         }
         return this._player2Aliens[param2].currentEffects;
      }
      
      public function GetActiveAlienEffects() : Vector.<Effect>
      {
         if(this._activePlayer == 1)
         {
            return this._player1Aliens[this._player1AlienIndex].currentEffects;
         }
         return this._player2Aliens[this._player2AlienIndex].currentEffects;
      }
      
      public function GetEnemyAlienEffects() : Vector.<Effect>
      {
         if(this._activePlayer == 1)
         {
            return this._player2Aliens[this._player2AlienIndex].currentEffects;
         }
         return this._player1Aliens[this._player1AlienIndex].currentEffects;
      }
      
      public function GetAlienIndex(param1:int, param2:Alien) : int
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:Vector.<Alien> = null;
         if(param1 == 1)
         {
            _loc5_ = this._player1Aliens;
         }
         else
         {
            _loc5_ = this._player2Aliens;
         }
         _loc3_ = 0;
         _loc4_ = true;
         while(_loc4_ && _loc3_ < _loc5_.length)
         {
            if(_loc5_[_loc3_] == param2)
            {
               _loc4_ = false;
            }
            else
            {
               _loc3_++;
            }
         }
         if(_loc4_)
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }
      
      public function GetPlayerAlienByIndex(param1:int, param2:int) : Alien
      {
         if(param1 == 1)
         {
            return this._player1Aliens[param2];
         }
         return this._player2Aliens[param2];
      }
      
      public function GetPlayerAliens(param1:int) : Vector.<Alien>
      {
         if(param1 == 1)
         {
            return this._player1Aliens;
         }
         return this._player2Aliens;
      }
      
      public function GetEnemyCurrentAlien() : Alien
      {
         if(this._activePlayer == 2)
         {
            return this._player1Aliens[this._player1AlienIndex];
         }
         return this._player2Aliens[this._player2AlienIndex];
      }
      
      public function isActiveAlienAffectedByEffect(param1:String) : Boolean
      {
         var _loc2_:Alien = null;
         if(this._activePlayer == 1)
         {
            _loc2_ = this._player1Aliens[this._player1AlienIndex];
         }
         else
         {
            _loc2_ = this._player2Aliens[this._player2AlienIndex];
         }
         return _loc2_.SearchEffect(param1);
      }
      
      public function ChooseNextAlien() : void
      {
         if(this._activePlayer == 1)
         {
            this._battleHUD.ShowAliensMenuForNextAlien();
         }
         else
         {
            this.SwapAlien(this._activePlayer,this._player2.ChooseNextAlien());
         }
      }
      
      public function SwapAlien(param1:int, param2:int) : void
      {
         this._swapTargetPlayer = param1;
         this._swapTargetAlien = param2;
         this.SetState(STATE_SWAP);
      }
      
      public function SwapRandomEnemyAlien() : void
      {
         if(this._activePlayer == 1)
         {
            this._swapTargetPlayer = 2;
            this._swapTargetAlien = this.GetRandomAlienIndex(this._player2Aliens,this._player2AlienIndex);
         }
         else
         {
            this._swapTargetPlayer = 1;
            this._swapTargetAlien = this.GetRandomAlienIndex(this._player1Aliens,this._player1AlienIndex);
         }
         this.SetState(STATE_SWAP);
      }
      
      private function GetRandomAlienIndex(param1:Vector.<Alien>, param2:int) : int
      {
         var _loc3_:Alien = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var reserveFinalBoss:Boolean = false;
         if(GameManager.Instance.tournamentSelectedID == "Tournament9" && this._battleGame is Tournament && Tournament(this._battleGame).getFightNumber() == 4 && param1 == this._player2Aliens)
         {
            for(var support:int = 0; support < 3; support++)
            {
               if(param1[support].currentHp > 0) { reserveFinalBoss = true; }
            }
         }
         _loc4_ = new Array();
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            if(_loc5_ != param2 && !(reserveFinalBoss && _loc5_ == 3))
            {
               _loc3_ = param1[_loc5_];
               if(_loc3_.currentHp > 0)
               {
                  _loc4_.push(_loc5_);
               }
            }
            _loc5_++;
         }
         if(_loc4_.length == 0)
         {
            return param2;
         }
         return _loc4_[Math.ceil(Math.random() * _loc4_.length) - 1];
      }
      
      public function SwapCompleted() : void
      {
         this.SetNewActiveAlien(this._swapTargetPlayer,this._swapTargetAlien);
         this._battleHUD.UpdateSwapAliens(this._swapTargetPlayer);
         this._battleHUD.GetEffectsHUD(this._swapTargetPlayer).SetCurrentEffects(this.GetPlayerAlien(this._swapTargetPlayer).currentEffects);
      }
      
      private function SetNewActiveAlien(param1:int, param2:int) : void
      {
         if(param1 == 1)
         {
            this._player1AlienIndex = param2;
            this._battleHUD.SetUpAlienInfo(1);
         }
         else
         {
            this._player2AlienIndex = param2;
            this._battleHUD.SetUpAlienInfo(2);
         }
      }
      
      public function get activePlayerNumber() : int
      {
         return this._activePlayer;
      }
      
      public function get swapTargetPlayer() : int
      {
         return this._swapTargetPlayer;
      }
      
      public function get swapTargetAlien() : int
      {
         return this._swapTargetAlien;
      }
      
      public function get previousState() : String
      {
         return this._previousState;
      }
      
      public function get skillUsed() : Skill
      {
         return this._skillUsed;
      }
      
      public function get damageDone() : int
      {
         return this._damageDone;
      }
      
      public function set damageDone(param1:int) : void
      {
         this._damageDone = param1;
      }
      
      public function get itemUsed() : Item
      {
         return this._itemUsed;
      }
      
      public function get itemTargetIndex() : int
      {
         return this._itemTargetIndex;
      }
      
      public function get xpRewardBonus() : int
      {
         return this._xpRewardBonus;
      }
      
      public function set xpRewardBonus(param1:int) : void
      {
         this._xpRewardBonus = param1;
      }
      
      public function get goldRewardBonus() : int
      {
         return this._goldRewardBonus;
      }
      
      public function set goldRewardBonus(param1:int) : void
      {
         this._goldRewardBonus = param1;
      }
      
      public function get actionsLeft() : int
      {
         return this._actionsLeft;
      }
      
      public function set actionsLeft(param1:int) : void
      {
         this._actionsLeft = param1;
      }
      
      public function get battleHUD() : BattleHUD
      {
         return this._battleHUD;
      }
      
      public function BattleIsOver() : void
      {
         this._player1.inventory.UpdatePersistance();
         Sfx.FadeSound(Sfx.currentMusicPlaying);
         HUDManager.Instance.Hide(true);
         this._battleHUD.HideView();
         if(this.Player1Won())
         {
            if(this._player1Aliens.length == 1 && this._player2Aliens.length >= 3)
            {
               MainApp.instance.EarnBadge("defeat_1_vs_3");
            }
            Sfx.PlayMusic("MusicScreens");
            MainApp.instance.OnGameEvent("BattleWon");
         }
         else
         {
            if(TutorialManager.Instance.IsActive())
            {
               if(TutorialManager.Instance.GetStep() == TutorialManager.STEP_TOURNAMENT)
               {
                  TutorialManager.Instance.StepComplete(TutorialManager.STEP_TOURNAMENT);
               }
            }
            MainApp.instance.OnGameEvent("BattleLost");
         }
      }
      
      public function GetRewards() : Object
      {
         var _loc1_:Object = null;
         _loc1_ = this._battleGame.getRewards();
         if(this._battleGame.getGameType() == BattleGame.GAME_TOURNAMENT && GameManager.Instance.tournamentSelectedID == "Tournament9")
         {
            return _loc1_;
         }
         _loc1_.PXP = int(_loc1_.PXP * (this._xpRewardBonus / 100));
         _loc1_.AXP = int(_loc1_.AXP * (this._xpRewardBonus / 100));
         _loc1_.PGold = int(_loc1_.PGold * (this._xpRewardBonus / 100));
         return _loc1_;
      }
      
      private function Player1Won() : Boolean
      {
         var _loc1_:Alien = null;
         var _loc2_:Boolean = false;
         for each(_loc1_ in this._player1Aliens)
         {
            if(_loc1_.currentHp > 0)
            {
               _loc2_ = true;
            }
         }
         return _loc2_;
      }
      
      public function SetNewEffectsToProcess(param1:Vector.<Effect>) : void
      {
         this._newEffectsToProcess = param1;
      }
      
      public function GetNewEffectsToProcess() : Vector.<Effect>
      {
         return this._newEffectsToProcess;
      }
      
      public function AlienUsedItem(param1:Item, param2:int) : void
      {
         this._itemUsed = param1;
         this._itemsUsed += "," + param1.id;
         this._itemTargetIndex = param2;
         this.SetState(STATE_ITEM);
      }
      
      public function AlienUsedSkill(param1:Skill) : void
      {
         this._skillUsed = param1;
         if(param1.type == Skill.ATTACK)
         {
            this.SetState(STATE_ATTACK);
         }
         else if(param1.type == Skill.DEFENSE)
         {
            this.SetState(STATE_DEFENSE);
         }
         if(this._skillUsed.mp_cost > 0)
         {
            this.GetPlayerAlien(this._activePlayer).currentMp = this.GetPlayerAlien(this._activePlayer).currentMp - this._skillUsed.mp_cost;
         }
      }
      
      public function EndTurn() : void
      {
         if(this._activePlayer == 1)
         {
            this._activePlayer = 2;
         }
         else
         {
            this._activePlayer = 1;
         }
         this.SetState(STATE_BEGIN_TURN);
      }
      
      public function GetPlayer() : Player
      {
         return this._player1;
      }
      
      public function GetAIPlayer() : AIPlayer
      {
         return this._player2;
      }
      
      public function Destroy() : void
      {
         if(this._initialized)
         {
            this.DestroyStates();
            this._player1.Destroy();
            this._player2.Destroy();
            this._player1 = null;
            this._player2 = null;
            this._player1Aliens = null;
            this._player2Aliens = null;
            this._battleGame = null;
            this._battleHUD.Destroy();
            this._battleHUD = null;
            if(this._background != null)
            {
               if(this._background.parent)
               {
                  this._background.parent.removeChild(this._background);
               }
            }
            this._background = null;
         }
         else
         {
            this._player1.Destroy();
            this._battleGame = null;
         }
      }
   }
}

