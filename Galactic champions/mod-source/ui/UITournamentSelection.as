package ui
{
   import battle.BattleGame;
   import buttons.RollOutBtn;
   import buttons.SoundButton;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import tutorial.TutorialManager;
   import txt.TextLoader;
   import view.ScreenModifier;
   
   public class UITournamentSelection extends UIWidget
   {
      
      private const OPTION_NONE:int = -1;
      
      private const OPTION_CLOSE:int = 0;
      
      private const OPTION_ACCEPT:int = 1;
      
      private const ITEM:String = "item";
      
      private const ALIEN:String = "alien";
      
      private const MEDAL:String = "medal";
      
      private const GOLD:String = "gold";
      
      private var _ultimateFeeCharged:Boolean = false;
      private var _ultimateTitle:TextField;

      private var _tournamentID:String;
      
      private var _currentTournament:int;
      
      private var _screenType:String;
      
      private var _tournamentsCount:int;
      
      private var _tournamentsDatas:Array;
      
      private var _currentTournamentData:Object;
      
      private var _leftScroll:RollOutBtn;
      
      private var _rightScroll:RollOutBtn;
      
      private var _optionSelected:int;
      
      private var _blurBitmap:Bitmap;
      
      public function UITournamentSelection(param1:MovieClip, param2:int = -1)
      {
         super(param1,param2);

         this._leftScroll = RollOutBtn(_view.getChildByName("scrollLeft"));
         this._rightScroll = RollOutBtn(_view.getChildByName("scrollRight"));
         RollOutBtn(View.getChildByName("close_btn")).clickSoundId = "ClickSnd";
         Sfx.AddSoundButton(SoundButton(View.getChildByName("sound_btn")));
      }
      
      private function AddButtonsEventListeners() : void
      {
         this._leftScroll.HitArea.addEventListener(MouseEvent.CLICK,this.OnLeftClick);
         this._rightScroll.HitArea.addEventListener(MouseEvent.CLICK,this.OnRightClick);
         RollOutBtn(MovieClip(_view.getChildByName("playContainer")).getChildByName("accept_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnAcceptButtonClick);
         RollOutBtn(_view.getChildByName("close_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnCloseButtonClick);
      }
      
      private function RemoveListenersFromButtons() : void
      {
         this._leftScroll.HitArea.removeEventListener(MouseEvent.CLICK,this.OnLeftClick);
         this._rightScroll.HitArea.removeEventListener(MouseEvent.CLICK,this.OnRightClick);
         RollOutBtn(MovieClip(_view.getChildByName("playContainer")).getChildByName("accept_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnAcceptButtonClick);
         RollOutBtn(_view.getChildByName("close_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnCloseButtonClick);
      }
      
      private function OnAcceptButtonClick(param1:MouseEvent) : void
      {
         if(GameManager.Instance.player.gold >= int(this._currentTournamentData.gold_req))
         {
            if(this._currentTournamentData.id == "Tournament9")
            {
               if(GameManager.Instance.player.level < 25) { return; }
               this.ChargeFee();
            }
            this._optionSelected = this.OPTION_ACCEPT;
            this.FadeOut();
         }
         else
         {
            UIFactory.Instance.NoGoldWarning.FadeIn();
         }
      }
      
      private function OnCloseButtonClick(param1:MouseEvent) : void
      {
         this._optionSelected = this.OPTION_CLOSE;
         this.FadeOut();
      }
      
      override public function OnFadeOutOver(param1:Event) : void
      {
         super.OnFadeOutOver(param1);
         if(this._optionSelected == this.OPTION_ACCEPT)
         {
            GameManager.Instance.tournamentSelectedID = this._tournamentID;
            UIFactory.Instance.TeamSelection.gameType = BattleGame.GAME_TOURNAMENT;
            UIFactory.Instance.TeamSelection.alienPreChosen = String(this._currentTournamentData.alien_req);
            UIFactory.Instance.TeamSelection.FadeIn();
         }
      }
      
      override public function OnFadeInOver(param1:Event) : void
      {
         super.OnFadeInOver(param1);
         this.AddButtonsEventListeners();
      }
      
      private function ResetScreen() : void
      {
         this._tournamentsDatas = JasonConfigLoader.Instance.data.tournaments as Array;
         this._tournamentsCount = this._tournamentsDatas.length;
         this.SearchNextTournament();
         this._ultimateFeeCharged = false;
         this._optionSelected = this.OPTION_NONE;
         this.ShowTournamentInfo();
         if(TutorialManager.Instance.IsActive())
         {
            _view.getChildByName("close_btn").visible = false;
            this._leftScroll.visible = false;
            this._rightScroll.visible = false;
         }
         else
         {
            _view.getChildByName("close_btn").visible = true;
         }
      }
      
      private function SearchNextTournament() : void
      {
         var _loc1_:Boolean = false;
         _loc1_ = true;
         this._currentTournament = 1;
         while(this._currentTournament <= 8 && _loc1_)
         {
            if(!GameManager.Instance.player.hasMedal("Card" + this._currentTournament))
            {
               _loc1_ = false;
            }
            else
            {
               ++this._currentTournament;
            }
         }
         if(_loc1_)
         {
            this._currentTournament = 8;
         }
      }
      
      private function OnLeftClick(param1:MouseEvent) : void
      {
         --this._currentTournament;
         if(this._currentTournament < 1)
         {
            this._currentTournament = 1;
         }
         this.ShowTournamentInfo();
      }
      
      private function OnRightClick(param1:MouseEvent) : void
      {
         ++this._currentTournament;
         if(this._currentTournament > this._tournamentsCount)
         {
            this._currentTournament = this._tournamentsCount;
         }
         this.ShowTournamentInfo();
      }
      
      private function CheckScrollButtons() : void
      {
         this._leftScroll.visible = this._currentTournament > 1;
         this._rightScroll.visible = this._currentTournament < this._tournamentsCount;
      }
      
      private function ShowTournamentInfo() : void
      {
         this._tournamentID = "Tournament" + String(this._currentTournament);
         this._currentTournamentData = this._tournamentsDatas[this._currentTournament - 1];
         var titleField:TextField = TextField(MovieClip(_view.getChildByName("title")).getChildByName("title_txt"));
         if(this._ultimateTitle == null)
         {
            this._ultimateTitle = new TextField();
            this._ultimateTitle.defaultTextFormat = new TextFormat("Arial",32,0xffffff,true);
            this._ultimateTitle.width = 650;
            this._ultimateTitle.height = 50;
            this._ultimateTitle.x = 50;
            this._ultimateTitle.y = 15;
            this._ultimateTitle.text = "ULTIMATE TOURNAMENT 1";
            this._ultimateTitle.mouseEnabled = false;
            _view.addChild(this._ultimateTitle);
         }
         this._ultimateTitle.visible = this._currentTournamentData.id == "Tournament9";
         titleField.visible = this._currentTournamentData.id != "Tournament9";

         TextField(MovieClip(_view.getChildByName("title")).getChildByName("title_txt")).text = String(TextLoader.Instance.Texts[String(this._currentTournamentData.id) + "_Name"]);
         MovieClip(_view.getChildByName("base")).gotoAndStop(this._currentTournamentData.id == "Tournament9" ? "Tournament1" : String(this._currentTournamentData.id));
         MovieClip(_view.getChildByName("boss_mc")).gotoAndStop(String(this._currentTournamentData.id));
         _view.getChildByName("tournamentWon").visible = GameManager.Instance.player.hasMedal("Card" + String(this._currentTournament));
         this.SetUpRequirements();
         this.SetUpRewards();
         this.CheckScrollButtons();
      }
      
      private function SetUpRequirements() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         _loc1_ = 0;
         _loc5_ = true;
         _loc4_ = MovieClip(_view.getChildByName("requirements"));
         _loc1_++;
         _loc3_ = MovieClip(_loc4_.getChildByName("req" + _loc1_));
         this.HideAll(_loc3_);
         _loc3_ = MovieClip(_loc3_.getChildByName("lvl"));
         _loc3_.visible = true;
         TextField(_loc3_.getChildByName("level")).text = String(this._currentTournamentData.level_req);
         if(GameManager.Instance.player.level < int(this._currentTournamentData.level_req))
         {
            _loc5_ = false;
         }
         _loc6_ = String(this._currentTournamentData.alien_req);
         if(_loc6_ != "none")
         {
            _loc1_++;
            _loc3_ = MovieClip(_loc4_.getChildByName("req" + _loc1_));
            this.HideAll(_loc3_);
            _loc3_ = MovieClip(_loc3_.getChildByName("alien"));
            _loc3_.visible = true;
            _loc3_.gotoAndStop("on");
            MovieClip(_loc3_.getChildByName("face")).gotoAndStop(_loc6_);
            TextField(MovieClip(_loc3_.getChildByName("descriptionMc")).getChildByName("description")).text = String(TextLoader.Instance.Texts[_loc6_ + "Name"]).toUpperCase();
            if(GameManager.Instance.player.getAlienInfoById(_loc6_) == null)
            {
               _loc5_ = false;
            }
         }
         if(int(this._currentTournamentData.gold_req) > 0)
         {
            _loc1_++;
            _loc3_ = MovieClip(_loc4_.getChildByName("req" + _loc1_));
            this.HideAll(_loc3_);
            _loc3_ = MovieClip(_loc3_.getChildByName("gold"));
            _loc3_.visible = true;
            TextField(MovieClip(_loc3_.getChildByName("descriptionMc")).getChildByName("description")).text = String(this._currentTournamentData.gold_req);
         }
         if(_loc1_ > 1)
         {
            TextField(MovieClip(_loc4_.getChildByName("requiremenstTitle")).getChildByName("requirementsText")).text = String(TextLoader.Instance.Texts["tournamentRequirements"]);
         }
         else
         {
            TextField(MovieClip(_loc4_.getChildByName("requiremenstTitle")).getChildByName("requirementsText")).text = String(TextLoader.Instance.Texts["tournamentRequirement"]);
         }
         _loc4_.gotoAndStop("Requirements" + _loc1_);
         if(_loc5_)
         {
            RollOutBtn(MovieClip(_view.getChildByName("playContainer")).getChildByName("accept_btn")).Enable();
         }
         else
         {
            RollOutBtn(MovieClip(_view.getChildByName("playContainer")).getChildByName("accept_btn")).Disable();
         }
      }
      
      private function SetUpRewards() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         _loc1_ = 0;
         _loc2_ = MovieClip(_view.getChildByName("rewards"));
         if(int(this._currentTournamentData.reward_gold) > 0 || this._currentTournamentData.id == "Tournament9")
         {
            _loc1_++;
            _loc3_ = MovieClip(_loc2_.getChildByName("reward" + _loc1_));
            this.HideAll(_loc3_);
            _loc3_ = MovieClip(_loc3_.getChildByName(this.GOLD));
            _loc3_.visible = true;
            TextField(MovieClip(_loc3_.getChildByName("descriptionMc")).getChildByName("description")).text = this._currentTournamentData.id == "Tournament9" ? "15000" : String(this._currentTournamentData.reward_gold);
         }
         if(String(this._currentTournamentData.reward_item) != "none")
         {
            _loc1_++;
            _loc3_ = MovieClip(_loc2_.getChildByName("reward" + _loc1_));
            this.HideAll(_loc3_);
            _loc3_ = MovieClip(_loc3_.getChildByName(this.ITEM));
            _loc3_.visible = true;
            MovieClip(_loc3_.getChildByName("icon")).gotoAndStop(String(this._currentTournamentData.reward_item));
            TextField(MovieClip(_loc3_.getChildByName("descriptionMc")).getChildByName("description")).text = String(TextLoader.Instance.Texts["Item_" + String(this._currentTournamentData.reward_item) + "_Name"]).toUpperCase();
         }
         if(String(this._currentTournamentData.reward_alien) != "none")
         {
            _loc1_++;
            _loc3_ = MovieClip(_loc2_.getChildByName("reward" + _loc1_));
            this.HideAll(_loc3_);
            _loc3_ = MovieClip(_loc3_.getChildByName(this.ALIEN));
            _loc3_.visible = true;
            MovieClip(_loc3_.getChildByName("face")).gotoAndStop(String(this._currentTournamentData.reward_alien));
            TextField(MovieClip(_loc3_.getChildByName("descriptionMc")).getChildByName("description")).text = String(TextLoader.Instance.Texts[String(this._currentTournamentData.reward_alien) + "Name"]).toUpperCase();
         }
         if(_loc1_ > 1)
         {
            TextField(MovieClip(_loc2_.getChildByName("rewardTitle")).getChildByName("title")).text = String(TextLoader.Instance.Texts["tournamentRewards"]);
         }
         else
         {
            TextField(MovieClip(_loc2_.getChildByName("rewardTitle")).getChildByName("title")).text = String(TextLoader.Instance.Texts["tournamentReward"]);
         }
         _loc2_.gotoAndStop("Rewards" + _loc1_);
      }
      
      private function HideAll(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.numChildren)
         {
            param1.getChildAt(_loc2_).visible = false;
            _loc2_++;
         }
      }
      
      override public function FadeIn() : void
      {
         this.ResetScreen();
         UIFactory.Instance.Map.PopUpOpen();
         super.FadeIn();
      }
      
      override public function ShowFadedIn() : void
      {
         this.ResetScreen();
         UIFactory.Instance.Map.PopUpOpen();
         super.ShowFadedIn();
      }
      
      override public function Hide() : void
      {
         if(this._optionSelected == this.OPTION_CLOSE)
         {
            this.RemoveBlur();
         }
         this.RemoveListenersFromButtons();
         super.Hide();
      }
      
      override public function FadeOut() : void
      {
         if(this._optionSelected == this.OPTION_CLOSE)
         {
            UIFactory.Instance.Map.PopUpClose();
            this.UnBlurBack(0);
         }
         this.RemoveListenersFromButtons();
         super.FadeOut();
      }
      
      public function ChargeFee() : void
      {
         if(this._currentTournamentData != null && this._currentTournamentData.id == "Tournament9")
         {
            if(this._ultimateFeeCharged) { return; }
            this._ultimateFeeCharged = true;
         }
         if(this._currentTournamentData != null)
         {
            if(int(this._currentTournamentData.gold_req) > 0)
            {
               GameManager.Instance.player.gold -= int(this._currentTournamentData.gold_req);
               Persistence.setValue("playerGold",GameManager.Instance.player.gold);
               UIFactory.Instance.Map.UpdatePlayerGold();
            }
         }
      }
      
      private function BlurBack(param1:Number) : void
      {
         this.RemoveBlur();
         this._blurBitmap = ScreenModifier.CaptureBackground();
         MovieClip(_view.getChildByName("blurContainer")).addChild(this._blurBitmap);
         ScreenModifier.BlurBitmap(this._blurBitmap,param1);
      }
      
      private function UnBlurBack(param1:Number) : void
      {
         if(this._blurBitmap != null)
         {
            ScreenModifier.UnBlurBitmap(this._blurBitmap,param1,this.RemoveBlur);
         }
      }
      
      private function RemoveBlur() : void
      {
         if(this._blurBitmap != null)
         {
            if(this._blurBitmap.parent != null)
            {
               this._blurBitmap.parent.removeChild(this._blurBitmap);
            }
            this._blurBitmap = null;
         }
      }
   }
}

