package ui
{
   import battle.BattleGame;
   import buttons.RollOutBtn;
   import buttons.SoundButton;
   import com.greensock.TweenLite;
   import com.greensock.easing.Linear;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import players.LevelCalculator;
   import players.Player;
   import tutorial.TutorialManager;
   
   public class UIMap extends UIWidget
   {
      
      private var _newRewards:Object;
      
      private var _previousPlayerLevel:Number;
      
      private var _watch:MovieClip;
      
      public function UIMap(param1:MovieClip, param2:int = -1)
      {
         super(param1,param2);
         this._watch = MovieClip(MovieClip(MovieClip(_view.getChildByName("watch")).getChildByName("watch")).getChildByName("watch"));
         MovieClip(_view.getChildByName("player_lvl_info")).mouseChildren = false;
         MovieClip(_view.getChildByName("player_lvl_info")).mouseEnabled = false;
         RollOutBtn(_view.getChildByName("shop_btn")).OverSoundId = "MapRollOverAreaSnd";
         RollOutBtn(_view.getChildByName("quick_fight_btn")).OverSoundId = "MapRollOverAreaSnd";
         RollOutBtn(_view.getChildByName("tournament_btn")).OverSoundId = "MapRollOverAreaSnd";
         RollOutBtn(_view.getChildByName("aliens_btn")).OverSoundId = "MapRollOverAreaSnd";
         _view.addEventListener("PlayFadeInSnd",this.OnPlayFadeInSnd);
         _view.addEventListener("PlayMapMusic",this.OnPlayMapMusic);
         Sfx.AddSoundButton(SoundButton(View.getChildByName("sound_btn")));
      }
      
      override public function OnFadeInOver(param1:Event) : void
      {
         super.OnFadeInOver(param1);
         HUDManager.Instance.Hide(true);
         this._newRewards = Persistence.getValue("newRewards");
         this._previousPlayerLevel = GameManager.Instance.player.level;
         this.CheckNewRewards();
      }
      
      public function PopUpOpen() : void
      {
         _view.gotoAndPlay("PopUpIN");
      }
      
      public function PopUpClose() : void
      {
         Sfx.PlaySound("MapPopUpCloseSnd");
         this.CheckWatchTutorialVisibility();
         _view.gotoAndPlay("PopUpOUT");
         MovieClip(_view.getChildByName("watch")).gotoAndPlay("intro2");
         MovieClip(_view.getChildByName("watch")).addEventListener("OmnitrixTurnOn",this.OnOmnitrixTurnOn);
      }
      
      override public function Hide() : void
      {
         this.RemoveListenersFromButtons();
         super.Hide();
      }
      
      public function UpdatePlayerWatch() : void
      {
         MovieClip(this._watch.getChildByName("base")).gotoAndStop(GameManager.Instance.player.watchID);
      }
      
      private function AddListenersToButtons() : void
      {
         _view.getChildByName("clickBlocker").visible = false;
         RollOutBtn(_view.getChildByName("shop_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnShopButtonClick);
         RollOutBtn(_view.getChildByName("quick_fight_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnQuickFightButtonClick);
         RollOutBtn(_view.getChildByName("tournament_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnTournamentClick);
         RollOutBtn(_view.getChildByName("aliens_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnAliensButtonClick);
         MovieClip(_view.getChildByName("player_medals_info")).buttonMode = true;
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).addEventListener(MouseEvent.CLICK,this.onMedalsClick);
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).addEventListener(MouseEvent.MOUSE_OVER,this.onMedalsOver);
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).addEventListener(MouseEvent.MOUSE_OUT,this.onMedalsOut);
         this._watch.buttonMode = true;
         MovieClip(this._watch.getChildByName("hitArea_mc")).addEventListener(MouseEvent.CLICK,this.onWatchClick);
         MovieClip(this._watch.getChildByName("hitArea_mc")).addEventListener(MouseEvent.MOUSE_OVER,this.onWatchOver);
         MovieClip(this._watch.getChildByName("hitArea_mc")).addEventListener(MouseEvent.MOUSE_OUT,this.onWatchOut);
      }
      
      private function onMedalsOver(param1:MouseEvent) : void
      {
         Sfx.PlaySound("MapRollOverCardsSnd");
         MovieClip(_view.getChildByName("player_medals_info")).gotoAndPlay("over");
      }
      
      private function onMedalsOut(param1:MouseEvent) : void
      {
         MovieClip(_view.getChildByName("player_medals_info")).gotoAndPlay("out");
      }
      
      private function onMedalsClick(param1:MouseEvent) : void
      {
         Sfx.PlaySound("ClickSnd");
         UIFactory.Instance.CardsScreen.FadeIn();
      }
      
      private function onWatchOver(param1:MouseEvent) : void
      {
         Sfx.PlaySound("RollOverOmnitrix");
         this._watch.gotoAndPlay("over");
      }
      
      private function onWatchOut(param1:MouseEvent) : void
      {
         this._watch.gotoAndPlay("out");
      }
      
      private function onWatchClick(param1:MouseEvent) : void
      {
         Sfx.PlaySound("ClickOmnitrix");
         UIFactory.Instance.WatchSelection.FadeIn();
      }
      
      private function RemoveListenersFromButtons() : void
      {
         _view.getChildByName("clickBlocker").visible = true;
         RollOutBtn(_view.getChildByName("shop_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnShopButtonClick);
         RollOutBtn(_view.getChildByName("quick_fight_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnQuickFightButtonClick);
         RollOutBtn(_view.getChildByName("tournament_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnTournamentClick);
         RollOutBtn(_view.getChildByName("aliens_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnAliensButtonClick);
         MovieClip(_view.getChildByName("player_medals_info")).buttonMode = false;
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).removeEventListener(MouseEvent.CLICK,this.onMedalsClick);
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).removeEventListener(MouseEvent.MOUSE_OVER,this.onMedalsOver);
         MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("hitArea_mc")).removeEventListener(MouseEvent.MOUSE_OUT,this.onMedalsOut);
         this._watch.buttonMode = false;
         MovieClip(this._watch.getChildByName("hitArea_mc")).removeEventListener(MouseEvent.CLICK,this.onWatchClick);
         MovieClip(this._watch.getChildByName("hitArea_mc")).removeEventListener(MouseEvent.MOUSE_OVER,this.onWatchOver);
         MovieClip(this._watch.getChildByName("hitArea_mc")).removeEventListener(MouseEvent.MOUSE_OUT,this.onWatchOut);
      }
      
      private function OnShopButtonClick(param1:MouseEvent) : void
      {
         Sfx.PlaySound("MapOpenShopSnd");
         UIFactory.Instance.Shop.FadeIn();
      }
      
      private function OnTournamentClick(param1:MouseEvent) : void
      {
         if(TutorialManager.Instance.IsActive())
         {
            TutorialManager.Instance.StepComplete(TutorialManager.STEP_TOURNAMENT_INTRO);
            RollOutBtn(_view.getChildByName("shop_btn")).Enable();
            RollOutBtn(_view.getChildByName("quick_fight_btn")).Enable();
            RollOutBtn(_view.getChildByName("tournament_btn")).Enable();
            RollOutBtn(_view.getChildByName("aliens_btn")).Enable();
            TutorialManager.Instance.HideAll();
         }
         Sfx.PlaySound("MapOpenTournamentSnd");
         UIFactory.Instance.TournamentSelection.FadeIn();
      }
      
      private function OnQuickFightButtonClick(param1:MouseEvent) : void
      {
         if(TutorialManager.Instance.IsActive())
         {
            TutorialManager.Instance.StepComplete(TutorialManager.STEP_FIGHT_INTRO);
            RollOutBtn(_view.getChildByName("shop_btn")).Enable();
            RollOutBtn(_view.getChildByName("quick_fight_btn")).Enable();
            RollOutBtn(_view.getChildByName("tournament_btn")).Enable();
            RollOutBtn(_view.getChildByName("aliens_btn")).Enable();
            TutorialManager.Instance.ShowCurrentStep();
         }
         UIFactory.Instance.TeamSelection.gameType = BattleGame.GAME_QUICK_BATTLE;
         UIFactory.Instance.TeamSelection.alienPreChosen = "none";
         UIFactory.Instance.TeamSelection.FadeIn();
      }
      
      private function OnAliensButtonClick(param1:MouseEvent) : void
      {
         if(TutorialManager.Instance.IsActive())
         {
            TutorialManager.Instance.StepComplete(TutorialManager.STEP_TRAINING_INTRO);
            RollOutBtn(_view.getChildByName("shop_btn")).Enable();
            RollOutBtn(_view.getChildByName("quick_fight_btn")).Enable();
            RollOutBtn(_view.getChildByName("tournament_btn")).Enable();
            RollOutBtn(_view.getChildByName("aliens_btn")).Enable();
            TutorialManager.Instance.HideAll();
         }
         UIFactory.Instance.AlienTraining.FadeIn();
         Sfx.PlaySound("MapOpenTrainingSnd");
      }
      
      override public function ShowFadedIn() : void
      {
         this.SetUpPlayerInfo();
         super.ShowFadedIn();
      }
      
      override public function OnFadeOut(param1:Event) : void
      {
         this.RemoveListenersFromButtons();
         super.OnFadeOut(param1);
      }
      
      override public function FadeIn() : void
      {
         Sfx.FadeSound(Sfx.currentMusicPlaying);
         MovieClip(_view.getChildByName("watch")).gotoAndPlay("intro");
         MovieClip(_view.getChildByName("watch")).addEventListener("OmnitrixTurnOn",this.OnOmnitrixTurnOn);
         this.SetUpPlayerInfo();
         super.FadeIn();
      }
      
      private function OnPlayFadeInSnd(param1:Event) : void
      {
         Sfx.PlaySound("MapFadeInSnd");
      }
      
      private function OnPlayMapMusic(param1:Event) : void
      {
         Sfx.PlayMusic("MusicMap");
      }
      
      private function OnOmnitrixTurnOn(param1:Event) : void
      {
         MovieClip(_view.getChildByName("watch")).removeEventListener("OmnitrixTurnOn",this.OnOmnitrixTurnOn);
         if(_view.getChildByName("watch").visible == true)
         {
            Sfx.PlaySound("OmnitrixStartUp");
         }
      }
      
      public function EnableQuickBattle() : void
      {
         this.AddListenersToButtons();
         RollOutBtn(_view.getChildByName("shop_btn")).Disable();
         RollOutBtn(_view.getChildByName("quick_fight_btn")).Enable();
         RollOutBtn(_view.getChildByName("tournament_btn")).Disable();
         RollOutBtn(_view.getChildByName("aliens_btn")).Disable();
      }
      
      public function EnableTraining() : void
      {
         this.AddListenersToButtons();
         RollOutBtn(_view.getChildByName("shop_btn")).Disable();
         RollOutBtn(_view.getChildByName("quick_fight_btn")).Disable();
         RollOutBtn(_view.getChildByName("tournament_btn")).Disable();
         RollOutBtn(_view.getChildByName("aliens_btn")).Enable();
      }
      
      public function EnableTournament() : void
      {
         this.AddListenersToButtons();
         RollOutBtn(_view.getChildByName("shop_btn")).Disable();
         RollOutBtn(_view.getChildByName("quick_fight_btn")).Disable();
         RollOutBtn(_view.getChildByName("tournament_btn")).Enable();
         RollOutBtn(_view.getChildByName("aliens_btn")).Disable();
      }
      
      public function UpdatePlayerGold() : void
      {
         TextField(MovieClip(_view.getChildByName("player_gold_info")).getChildByName("gold_number")).text = String(GameManager.Instance.player.gold);
      }
      
      public function UpdatePlayerMedals() : void
      {
         var _loc1_:Player = null;
         _loc1_ = GameManager.Instance.player;
         TextField(MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("medals")).getChildByName("current")).text = String(_loc1_.medals.length);
         TextField(MovieClip(MovieClip(_view.getChildByName("player_medals_info")).getChildByName("medals")).getChildByName("max")).text = String(8);
      }
      
      public function UpdatePlayerXP(param1:Boolean = true) : void
      {
         var _loc2_:Player = null;
         _loc2_ = GameManager.Instance.player;
         TextField(MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("level")).getChildByName("level_number")).text = String(_loc2_.level);
         if(!param1)
         {
            this.UpdateXPBar(LevelCalculator.GetPlayerLevelMaxXP(_loc2_.level - 1),LevelCalculator.GetPlayerLevelMaxXP(_loc2_.level),_loc2_.xp,MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_value")),MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_bar")),param1);
         }
         else if(this._previousPlayerLevel != _loc2_.level)
         {
            TweenLite.to(MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_bar")),1,{
               "frame":100,
               "ease":Linear.easeNone,
               "onComplete":this.onBarTo100
            });
         }
         else
         {
            this.UpdateXPBar(LevelCalculator.GetPlayerLevelMaxXP(_loc2_.level - 1),LevelCalculator.GetPlayerLevelMaxXP(_loc2_.level),_loc2_.xp,MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_value")),MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_bar")),param1);
         }
      }
      
      private function onBarTo100() : void
      {
         var _loc1_:Player = null;
         _loc1_ = GameManager.Instance.player;
         MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_bar")).gotoAndStop(1);
         this.UpdateXPBar(LevelCalculator.GetPlayerLevelMaxXP(_loc1_.level - 1),LevelCalculator.GetPlayerLevelMaxXP(_loc1_.level),_loc1_.xp,MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_value")),MovieClip(MovieClip(_view.getChildByName("player_lvl_info")).getChildByName("lvl_bar")),true);
      }
      
      private function SetUpPlayerInfo() : void
      {
         this.CheckWatchTutorialVisibility();
         this.UpdatePlayerXP(false);
         this.UpdatePlayerGold();
         this.UpdatePlayerMedals();
         this.UpdatePlayerWatch();
      }
      
      private function CheckWatchTutorialVisibility() : void
      {
         var _loc1_:Boolean = false;
         if(TutorialManager.Instance.IsActive())
         {
            _loc1_ = TutorialManager.Instance.GetStep() >= TutorialManager.STEP_WATCH_SELECTION;
            _view.getChildByName("watch").visible = _loc1_;
            _view.getChildByName("player_lvl_info").visible = _loc1_;
         }
      }
      
      private function UpdateXPBar(param1:int, param2:int, param3:int, param4:MovieClip, param5:MovieClip, param6:Boolean = false, param7:Function = null) : void
      {
         var _loc8_:int = 0;
         if(!param6)
         {
            if(param1 >= param2)
            {
               _loc8_ = 101;
            }
            else
            {
               _loc8_ = Math.ceil((param3 - param1) / (param2 - param1) * 100) + 1;
               if(_loc8_ > 101)
               {
                  _loc8_ = 101;
               }
            }
            TextField(param4.getChildByName("current")).text = String(param3 - param1);
            TextField(param4.getChildByName("max")).text = String(param2 - param1);
            param5.gotoAndStop(_loc8_);
         }
         else
         {
            TextField(param4.getChildByName("current")).text = String(param3 - param1);
            TextField(param4.getChildByName("max")).text = String(param2 - param1);
            if(param1 >= param2)
            {
               _loc8_ = 101;
            }
            else
            {
               _loc8_ = Math.ceil((param3 - param1) / (param2 - param1) * 100) + 1;
               if(_loc8_ > 101)
               {
                  _loc8_ = 101;
               }
            }
            if(_loc8_ != param5.currentFrame)
            {
               if(_loc8_ > param5.currentFrame)
               {
                  Sfx.PlaySound("BarUpSnd",false);
               }
               else
               {
                  Sfx.PlaySound("BarDownSnd",false);
               }
               TweenLite.to(param5,0.5,{
                  "frame":_loc8_,
                  "ease":Linear.easeNone,
                  "onComplete":param7
               });
            }
            else if(param7 != null)
            {
               param7();
            }
         }
      }
      
      public function CheckNewRewards() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         if(this._newRewards != null)
         {
            _loc3_ = false;
            if(int(this._newRewards.PXP) > 0)
            {
               UIFactory.Instance.MapReward.SetUpXPWon(int(this._newRewards.PXP));
               GameManager.Instance.player.xp += int(this._newRewards.PXP);
               Persistence.setValue("playerXP",GameManager.Instance.player.xp);
               this._newRewards.PXP = 0;
               _loc3_ = true;
            }
            else if(int(this._newRewards.PGold) > 0)
            {
               UIFactory.Instance.MapReward.SetUpGoldWon(int(this._newRewards.PGold));
               GameManager.Instance.player.gold += int(this._newRewards.PGold);
               Persistence.setValue("playerGold",GameManager.Instance.player.gold);
               this._newRewards.PGold = 0;
               _loc3_ = true;
            }
            else if(String(this._newRewards.Medals) != "none")
            {
               _loc4_ = String(this._newRewards.Medals).split(",");
               _loc2_ = String(_loc4_[0]);
               _loc1_ = "";
               for each(_loc5_ in _loc4_)
               {
                  if(_loc5_ != _loc2_)
                  {
                     if(_loc1_ == "")
                     {
                        _loc1_ = _loc5_;
                     }
                     else
                     {
                        _loc1_ += "," + _loc5_;
                     }
                  }
               }
               if(_loc1_ == "")
               {
                  _loc1_ = "none";
               }
               UIFactory.Instance.MapReward.SetUpMedalWon(_loc2_);
               GameManager.Instance.player.AddMedal(_loc2_);
               this._newRewards.Medals = _loc1_;
               _loc3_ = true;
            }
            else if(String(this._newRewards.Alien) != "none")
            {
               _loc6_ = String(this._newRewards.Alien).split(",");
               _loc2_ = String(_loc6_[0]);
               _loc1_ = "";
               for each(_loc7_ in _loc6_)
               {
                  if(_loc7_ != _loc2_)
                  {
                     if(_loc1_ == "")
                     {
                        _loc1_ = _loc7_;
                     }
                     else
                     {
                        _loc1_ += "," + _loc7_;
                     }
                  }
               }
               if(_loc1_ == "")
               {
                  _loc1_ = "none";
               }
               UIFactory.Instance.MapReward.SetUpAlienWon(_loc2_);
               GameManager.Instance.player.AddNewAlien(_loc2_);
               this._newRewards.Alien = _loc1_;
               _loc3_ = true;
            }
            else if(String(this._newRewards.Item) != "none")
            {
               _loc8_ = String(this._newRewards.Item).split(",");
               _loc2_ = String(_loc8_[0]);
               _loc1_ = "";
               for each(_loc9_ in _loc8_)
               {
                  if(_loc9_ != _loc2_)
                  {
                     if(_loc1_ == "")
                     {
                        _loc1_ = _loc9_;
                     }
                     else
                     {
                        _loc1_ += "," + _loc9_;
                     }
                  }
               }
               if(_loc1_ == "")
               {
                  _loc1_ = "none";
               }
               UIFactory.Instance.MapReward.SetUpItemWon(_loc2_);
               GameManager.Instance.player.inventory.AddItem(_loc2_,1,true);
               this._newRewards.Item = _loc1_;
               _loc3_ = true;
            }
            if(_loc3_)
            {
               this.RemoveListenersFromButtons();
               _view.getChildByName("clickBlocker").visible = false;
               UIFactory.Instance.MapReward.onConfirmation = this.CheckNewRewards;
               UIFactory.Instance.MapReward.FadeIn();
               Persistence.setValue("newRewards",this._newRewards);
            }
            else
            {
               this.CheckRewardsComplete();
            }
         }
         else
         {
            this.CheckRewardsComplete();
         }
      }
      
      private function CheckRewardsComplete() : void
      {
         if(TutorialManager.Instance.IsActive())
         {
            _view.getChildByName("clickBlocker").visible = false;
            TutorialManager.Instance.ShowCurrentStep();
         }
         else
         {
            this.AddListenersToButtons();
         }
      }
   }
}

