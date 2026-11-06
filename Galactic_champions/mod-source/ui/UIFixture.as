package ui
{
   import battle.Tournament;
   import buttons.RollOutBtn;
   import buttons.SoundButton;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import players.aliens.AlienInfoFactory;
   import tutorial.TutorialManager;
   import txt.TextLoader;
   import view.ScreenModifier;
   
   public class UIFixture extends UIWidget
   {
      
      private var _tournament:Tournament;
      
      private var _totalFights:int;
      
      private var _currentFight:int;
      
      private var _totalTeams:int;
      
      private var _playerTeamData:TournamentTeamData;
      
      private var _tournamentTeamsDatas:Vector.<Vector.<TournamentTeamData>>;
      
      private var _currentFixture:MovieClip;
      
      private var _container:MovieClip;
      
      private var _blurBitmap:Bitmap;
      
      public function UIFixture(param1:MovieClip, param2:int = -1)
      {
         super(param1,param2);
         this._container = MovieClip(_view.getChildByName("container_mc"));
         Sfx.AddSoundButton(SoundButton(this._container.getChildByName("sound_btn")));
      }
      
      override public function OnFadeInOver(param1:Event) : void
      {
         super.OnFadeInOver(param1);
         this.AddButtonsEventListeners();
      }
      
      public function TournamentCreated(param1:Tournament) : void
      {
         this._tournament = param1;
         this._totalFights = this._tournament.getTotalFights();
         this._totalTeams = Math.pow(2,this._totalFights);
         this._currentFixture = MovieClip(this._container.getChildByName("fightsfixture" + this._totalFights));
         this.CreateTeams();
         this.CreateProgression();
      }
      
      private function CreateTeams() : void
      {
         var _loc1_:TournamentTeamData = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Vector.<TournamentTeamData> = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         _loc5_ = this.CreateRandomAliensList(this._totalTeams - (this._totalFights + 1));
         _loc6_ = this.CreateRandomWatchList(this._totalTeams - 1,GameManager.Instance.player.watchID);
         _loc7_ = new Array();
         this._tournamentTeamsDatas = new Vector.<Vector.<TournamentTeamData>>();
         _loc4_ = new Vector.<TournamentTeamData>();
         _loc3_ = 1;
         _loc2_ = 1;
         while(_loc2_ <= this._totalTeams)
         {
            _loc1_ = new TournamentTeamData();
            if(_loc2_ == 1)
            {
               _loc1_.type = TournamentTeamData.PLAYER;
               _loc1_.leaderID = GameManager.Instance.player.GetTeamLeaderID();
               _loc1_.watchID = GameManager.Instance.player.watchID;
               this._playerTeamData = _loc1_;
            }
            else if(_loc2_ == Math.pow(2,_loc3_))
            {
               _loc1_.type = TournamentTeamData.WINNER;
               _loc1_.leaderID = this._tournament.getLeaderID(_loc3_);
               _loc1_.watchID = String(_loc6_.pop());
               _loc7_.push(_loc1_.watchID);
               _loc3_++;
            }
            else
            {
               _loc1_.type = TournamentTeamData.LOSER;
               _loc1_.leaderID = String(_loc5_.pop());
               _loc1_.watchID = String(_loc6_.pop());
            }
            _loc4_.push(_loc1_);
            _loc2_++;
         }
         this._tournament.setWatchIds(_loc7_);
         this.RandomizeTeamLocations(_loc4_);
         this._tournamentTeamsDatas.push(_loc4_);
      }
      
      private function RandomizeTeamLocations(param1:Vector.<TournamentTeamData>) : void
      {
         var _loc2_:TournamentTeamData = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _loc5_ = 1;
         while(_loc5_ <= param1.length / 2)
         {
            _loc3_ = 1;
            _loc4_ = _loc5_;
            while(_loc4_ + _loc5_ <= param1.length)
            {
               if(Math.random() > 0.5)
               {
                  _loc6_ = _loc3_;
                  while(_loc6_ <= _loc4_)
                  {
                     _loc2_ = param1[_loc6_ + _loc5_ - 1];
                     param1[_loc6_ + _loc5_ - 1] = param1[_loc6_ - 1];
                     param1[_loc6_ - 1] = _loc2_;
                     _loc6_++;
                  }
               }
               _loc3_ = _loc4_ + _loc5_ + 1;
               _loc4_ += 2 * _loc5_;
            }
            _loc5_ *= 2;
         }
      }
      
      private function CreateRandomAliensList(param1:int) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         _loc4_ = new Array();
         _loc2_ = GameManager.Instance.player.GetTeamLeaderID();
         _loc5_ = 1;
         while(_loc5_ <= this._totalFights)
         {
            _loc2_ = "," + this._tournament.getLeaderID(_loc5_);
            _loc5_++;
         }
         _loc3_ = AlienInfoFactory.GeneratePossibleAliensList(GameManager.Instance.player.GetMaxAlienLevel(),_loc2_);
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc7_ = 0;
            for each(_loc8_ in _loc3_)
            {
               _loc7_ += int(_loc8_.chance);
            }
            _loc9_ = Math.ceil(Math.random() * _loc7_);
            _loc10_ = true;
            _loc6_ = 0;
            while(_loc10_ && _loc6_ < _loc3_.length)
            {
               _loc8_ = _loc3_[_loc6_];
               _loc9_ -= int(_loc8_.chance);
               if(_loc9_ <= 0)
               {
                  _loc8_.chance = int(int(_loc8_.chance) / 2);
                  if(_loc8_.chance <= 0)
                  {
                     _loc8_.chance = 1;
                  }
                  _loc4_.push(String(_loc8_.id));
                  _loc10_ = false;
               }
               else
               {
                  _loc6_++;
               }
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function CreateRandomWatchList(param1:int, param2:String) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         _loc3_ = new Array();
         _loc5_ = new Array();
         _loc6_ = 1;
         while(_loc6_ <= 8)
         {
            _loc4_ = "Watch" + _loc6_;
            if(param2.indexOf(_loc4_) == -1)
            {
               _loc3_.push(_loc4_);
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            _loc5_.push(_loc3_[Math.ceil(Math.random() * _loc3_.length) - 1]);
            _loc6_++;
         }
         return _loc5_;
      }
      
      private function CreateProgression() : void
      {
         var _loc1_:Vector.<TournamentTeamData> = null;
         var _loc2_:Vector.<TournamentTeamData> = null;
         var _loc3_:TournamentTeamData = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:TournamentTeamData = null;
         var _loc7_:TournamentTeamData = null;
         var _loc8_:TournamentTeamData = null;
         _loc4_ = 2;
         while(_loc4_ <= this._totalFights)
         {
            _loc1_ = this._tournamentTeamsDatas[_loc4_ - 2];
            _loc2_ = new Vector.<TournamentTeamData>();
            _loc5_ = 0;
            while(_loc5_ < _loc1_.length)
            {
               _loc6_ = _loc1_[_loc5_];
               _loc7_ = _loc1_[_loc5_ + 1];
               _loc5_++;
               if(_loc6_.type == TournamentTeamData.PLAYER)
               {
                  _loc8_ = _loc6_.clone();
                  _loc7_.state = TournamentTeamData.STATE_DEAD;
               }
               else if(_loc6_.type == TournamentTeamData.WINNER)
               {
                  if(_loc7_.type == TournamentTeamData.PLAYER)
                  {
                     _loc8_ = _loc7_.clone();
                     _loc6_.state = TournamentTeamData.STATE_DEAD;
                  }
                  else
                  {
                     _loc8_ = _loc6_.clone();
                     _loc7_.state = TournamentTeamData.STATE_DEAD;
                  }
               }
               else if(_loc6_.type == TournamentTeamData.LOSER)
               {
                  if(_loc7_.type == TournamentTeamData.LOSER)
                  {
                     if(Math.random() < 0.5)
                     {
                        _loc8_ = _loc6_.clone();
                        _loc7_.state = TournamentTeamData.STATE_DEAD;
                     }
                     else
                     {
                        _loc8_ = _loc7_.clone();
                        _loc6_.state = TournamentTeamData.STATE_DEAD;
                     }
                  }
                  else
                  {
                     _loc8_ = _loc7_.clone();
                     _loc6_.state = TournamentTeamData.STATE_DEAD;
                  }
               }
               _loc2_.push(_loc8_);
               _loc5_++;
            }
            this._tournamentTeamsDatas.push(_loc2_);
            _loc4_++;
         }
      }
      
      private function ShowFightInfo(param1:Number) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc4_:Vector.<TournamentTeamData> = null;
         var _loc5_:int = 0;
         var _loc6_:MovieClip = null;
         TextField(MovieClip(this._container.getChildByName("title")).getChildByName("fixtureTitle")).text = this._tournament.getTournamentName().toUpperCase();
         this._container.getChildByName("fightsfixture2").visible = false;
         this._container.getChildByName("fightsfixture3").visible = false;
         this._container.getChildByName("fightsfixture4").visible = false;
         this._currentFixture.visible = true;
         _loc2_ = MovieClip(this._currentFixture.getChildByName("facesContainer"));
         _loc3_ = 1;
         while(_loc3_ <= this._totalFights)
         {
            _loc4_ = this._tournamentTeamsDatas[_loc3_ - 1];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = MovieClip(_loc2_.getChildByName("fight" + _loc3_ + "team" + (_loc5_ + 1)));
               if(_loc3_ < param1)
               {
                  MovieClip(_loc6_.getChildByName("picture")).gotoAndStop(_loc4_[_loc5_].leaderID);
                  TextField(MovieClip(_loc6_.getChildByName("alienName")).getChildByName("alienName_txt")).text = String(TextLoader.Instance.Texts[_loc4_[_loc5_].leaderID + "Name"]).toUpperCase();
                  MovieClip(_loc6_.getChildByName("watch")).gotoAndStop(_loc4_[_loc5_].watchID);
                  MovieClip(_loc6_.getChildByName("selector")).visible = false;
                  if(_loc4_[_loc5_].state == TournamentTeamData.STATE_ALIVE)
                  {
                     _loc6_.gotoAndStop("on");
                  }
                  else
                  {
                     _loc6_.gotoAndStop("off");
                  }
               }
               else if(_loc3_ == param1)
               {
                  MovieClip(_loc6_.getChildByName("picture")).gotoAndStop(_loc4_[_loc5_].leaderID);
                  TextField(MovieClip(_loc6_.getChildByName("alienName")).getChildByName("alienName_txt")).text = String(TextLoader.Instance.Texts[_loc4_[_loc5_].leaderID + "Name"]).toUpperCase();
                  MovieClip(_loc6_.getChildByName("watch")).gotoAndStop(_loc4_[_loc5_].watchID);
                  if(_loc4_[_loc5_].type == TournamentTeamData.PLAYER)
                  {
                     MovieClip(_loc6_.getChildByName("selector")).visible = !this._tournament.tournamentFinished;
                     _loc6_.gotoAndStop("on");
                  }
                  else
                  {
                     MovieClip(_loc6_.getChildByName("selector")).visible = false;
                     _loc6_.gotoAndStop("on");
                  }
               }
               else
               {
                  _loc6_.gotoAndStop("empty");
                  MovieClip(_loc6_.getChildByName("selector")).visible = false;
               }
               _loc5_++;
            }
            _loc3_++;
         }
         _loc6_ = MovieClip(_loc2_.getChildByName("champion"));
         this._currentFight = param1;
         if(this._tournament.tournamentFinished)
         {
            this.UpdateRewards();
            MovieClip(_loc6_.getChildByName("picture")).gotoAndStop(this._playerTeamData.leaderID);
            TextField(MovieClip(_loc6_.getChildByName("alienName")).getChildByName("alienName_txt")).text = String(TextLoader.Instance.Texts[this._playerTeamData.leaderID + "Name"]).toUpperCase();
            MovieClip(_loc6_.getChildByName("watch")).gotoAndStop(this._playerTeamData.watchID);
            MovieClip(_loc6_.getChildByName("selector")).visible = true;
            _loc6_.gotoAndStop("on");
            this._currentFixture.getChildByName("map_btn").visible = false;
            this._currentFixture.gotoAndStop("TournamentWon");
         }
         else
         {
            _loc6_.gotoAndStop("empty");
            MovieClip(_loc6_.getChildByName("selector")).visible = false;
            this._currentFixture.getChildByName("map_btn").visible = true;
            this._currentFixture.gotoAndStop("TournamentNotWon");
         }
      }
      
      private function UpdateRewards() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         _loc2_ = this._tournament.getTournamentRewards();
         _loc1_ = Persistence.getValue("newRewards");
         _loc3_ = String(_loc2_.Medals);
         if(_loc1_ != null)
         {
            _loc2_.PXP = int(_loc1_.PXP) + int(_loc2_.PXP);
            _loc2_.PGold = int(_loc1_.PGold) + int(_loc2_.PGold);
            _loc2_.AXP = int(_loc1_.AXP) + int(_loc2_.AXP);
            if(String(_loc1_.Medals) != "none")
            {
               if(String(_loc2_.Medals) != "none")
               {
                  _loc2_.Medals = String(_loc1_.Medals) + "," + String(_loc2_.Medals);
               }
               else
               {
                  _loc2_.Medals = String(_loc1_.Medals);
               }
            }
            if(String(_loc1_.Alien) != "none")
            {
               if(String(_loc2_.Alien) != "none")
               {
                  _loc2_.Alien = String(_loc1_.Alien) + "," + String(_loc2_.Alien);
               }
               else
               {
                  _loc2_.Alien = String(_loc1_.Alien);
               }
            }
            if(String(_loc1_.Item) != "none")
            {
               if(String(_loc2_.Item) != "none")
               {
                  _loc2_.Item = String(_loc1_.Item) + "," + String(_loc2_.Item);
               }
               else
               {
                  _loc2_.Item = String(_loc1_.Item);
               }
            }
         }
         Persistence.setValue("newRewards",_loc2_);
         this.CheckAchievement(_loc3_);
      }
      
      private function CheckAchievement(param1:String) : void
      {
         var _loc2_:int = 0;
         if(param1 != "none")
         {
            _loc2_ = GameManager.Instance.player.medals.length + 1;
            if(_loc2_ == 1)
            {
               MainApp.instance.EarnBadge("win_first_tournament");
            }
            else if(_loc2_ == 8)
            {
               MainApp.instance.EarnBadge("win_all_tournaments");
            }
         }
      }
      
      private function AddButtonsEventListeners() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         _loc2_ = 2;
         while(_loc2_ <= 4)
         {
            _loc1_ = MovieClip(this._container.getChildByName("fightsfixture" + _loc2_));
            RollOutBtn(_loc1_.getChildByName("play_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnPlayButtonClick);
            RollOutBtn(_loc1_.getChildByName("map_btn")).HitArea.addEventListener(MouseEvent.CLICK,this.OnMapButtonClick);
            RollOutBtn(_loc1_.getChildByName("map_btn")).clickSoundId = "ClickSnd";
            _loc2_++;
         }
      }
      
      private function RemoveListenersFromButtons() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         _loc2_ = 2;
         while(_loc2_ <= 4)
         {
            _loc1_ = MovieClip(this._container.getChildByName("fightsfixture" + _loc2_));
            RollOutBtn(_loc1_.getChildByName("play_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnPlayButtonClick);
            RollOutBtn(_loc1_.getChildByName("map_btn")).HitArea.removeEventListener(MouseEvent.CLICK,this.OnMapButtonClick);
            _loc2_++;
         }
      }
      
      private function OnPlayButtonClick(param1:MouseEvent) : void
      {
         this.RemoveListenersFromButtons();
         if(this._tournament.tournamentFinished)
         {
            this.RemoveListenersFromButtons();
            MainApp.instance.OnGameEvent("GoBackToMapFromBattle");
         }
         else
         {
            this.RemoveListenersFromButtons();
            MainApp.instance.OnGameEvent("FixturePlayClicked");
         }
      }
      
      private function OnMapButtonClick(param1:MouseEvent) : void
      {
         this.RemoveListenersFromButtons();
         MainApp.instance.OnGameEvent("GoBackToMapFromBattle");
      }
      
      private function SetUpScreen() : void
      {
         if(!Sfx.IsPlaying("MusicFixture"))
         {
            Sfx.FadeSound(Sfx.currentMusicPlaying);
            Sfx.PlayMusic("MusicFixture");
         }
         this.ShowFightInfo(this._tournament.getFightNumber());
         if(TutorialManager.Instance.IsActive())
         {
            this._currentFixture.getChildByName("map_btn").visible = false;
         }
      }
      
      override public function FadeIn() : void
      {
         this.SetUpScreen();
         this.BlurBack(0.2);
         super.FadeIn();
      }
      
      override public function ShowFadedIn() : void
      {
         this.SetUpScreen();
         this.BlurBack(0);
         super.ShowFadedIn();
      }
      
      override public function Hide() : void
      {
         this.RemoveBlur();
         this.RemoveListenersFromButtons();
         super.Hide();
      }
      
      override public function FadeOut() : void
      {
         this.UnBlurBack(0);
         this.RemoveListenersFromButtons();
         super.FadeOut();
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

