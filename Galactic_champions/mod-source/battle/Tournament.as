package battle
{
   import players.Player;
   import players.aliens.AlienInfo;
   import players.aliens.AlienInfoFactory;
   import txt.TextLoader;
   
   public class Tournament extends BattleGame
   {
      
      private var _id:String;
      
      private var _currentFight:int;
      
      private var _battlesInfos:Vector.<BattleInfo>;
      
      private var _tournamentInfo:Object;
      
      private var _tournamentFinished:Boolean;
      
      private var _tournamentWatchesIds:Array;
      
      public function Tournament(param1:String)
      {
         super();
         this._id = param1;
         _gameType = GAME_TOURNAMENT;
      }
      
      override public function setUp(param1:Player) : void
      {
         var _loc2_:BattleInfo = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Vector.<Vector.<AlienInfo>> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         super.setUp(param1);
         this._currentFight = 1;
         this.SearchTournamentInfo();
         this._tournamentFinished = false;
         _loc5_ = AlienInfoFactory.GetTournamentFightAliensInfos(this._id == "Tournament9" ? 25 : _player.GetMaxAlienLevel(),this._tournamentInfo.fightsInfos as Array);
         this._battlesInfos = new Vector.<BattleInfo>();
         _loc7_ = 0;
         for each(_loc3_ in (this._tournamentInfo.fightsInfos as Array))
         {
            _loc2_ = new BattleInfo();
            _loc2_.backGroundID = String(_loc3_.background);
            _loc2_.AIItems = "";
            for each(_loc4_ in (_loc3_.items as Array))
            {
               _loc6_ = 0;
               while(_loc6_ < int(_loc4_.amount))
               {
                  if(_loc2_.AIItems == "")
                  {
                     _loc2_.AIItems = String(_loc4_.itemID);
                  }
                  else
                  {
                     _loc2_.AIItems += "," + String(_loc4_.itemID);
                  }
                  _loc6_++;
               }
            }
            _loc2_.aliensInfos = _loc5_[_loc7_];
            _loc7_++;
            this._battlesInfos.push(_loc2_);
         }
      }
      
      private function SearchTournamentInfo() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         _loc3_ = JasonConfigLoader.Instance.data.tournaments as Array;
         _loc1_ = true;
         _loc2_ = 0;
         while(_loc1_ && _loc2_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc2_];
            if(String(_loc4_.id) == this._id)
            {
               _loc1_ = false;
            }
            else
            {
               _loc2_++;
            }
         }
         this._tournamentInfo = _loc4_;
      }
      
      public function getTournamentName() : String
      {
         return String(TextLoader.Instance.Texts[String(this._tournamentInfo.id) + "_Name"]);
      }
      
      public function getTotalFights() : int
      {
         return (this._tournamentInfo.fightsInfos as Array).length;
      }
      
      public function getFightNumber() : int
      {
         return this._currentFight;
      }
      
      override public function getAIInventoryData() : String
      {
         return this._battlesInfos[this._currentFight - 1].AIItems;
      }
      
      override public function getBattleBackgroundID() : String
      {
         return this._battlesInfos[this._currentFight - 1].backGroundID;
      }
      
      override public function getAIAlienInfosForBattle() : Vector.<AlienInfo>
      {
         return this._battlesInfos[this._currentFight - 1].aliensInfos;
      }
      
      override public function getAIAliensIdsForBattle() : String
      {
         var _loc2_:AlienInfo = null;
         var _loc1_:String = "";
         for each(_loc2_ in this._battlesInfos[this._currentFight - 1].aliensInfos)
         {
            if(_loc1_ == "")
            {
               _loc1_ += _loc2_.alienID;
            }
            else
            {
               _loc1_ += "," + _loc2_.alienID;
            }
         }
         return _loc1_;
      }
      
      public function getLeaderID(param1:int) : String
      {
         return this._battlesInfos[param1 - 1].aliensInfos[this._battlesInfos[param1 - 1].aliensInfos.length - 1].alienID;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._battlesInfos = null;
         this._tournamentInfo = null;
      }
      
      override public function getRewards() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:AlienInfo = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._id == "Tournament9")
         {
            return {"PXP":0,"PGold":int(this._tournamentInfo.fightsInfos[this._currentFight - 1].reward_gold),"Medals":"none","AXP":0,"Alien":"none","Item":"none"};
         }
         _loc3_ = 0;
         _loc4_ = 0;
         for each(_loc2_ in this._battlesInfos[this._currentFight - 1].aliensInfos)
         {
            _loc3_ += int(_loc2_.money_value * _loc2_.lvl * 1.5);
            _loc4_ += int(_loc2_.xp_value * _loc2_.lvl * 1.5 / 7);
         }
         return {
            "PXP":_loc4_,
            "PGold":_loc3_,
            "Medals":"none",
            "AXP":_loc4_,
            "Alien":"none",
            "Item":"none"
         };
      }
      
      public function getTournamentRewards() : Object
      {
         var _loc1_:Player = null;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(this._id == "Tournament9")
         {
            return {"PXP":0,"PGold":0,"Medals":"none","AXP":0,"Alien":"none","Item":"none"};
         }
         _loc3_ = int(this._tournamentInfo.reward_gold);
         _loc4_ = int(this._tournamentInfo.reward_xp);
         _loc5_ = String(this._tournamentInfo.reward_alien);
         _loc7_ = String(this._tournamentInfo.card);
         _loc6_ = String(this._tournamentInfo.reward_item);
         _loc1_ = GameManager.Instance.player;
         if(_loc1_.getAlienInfoById(_loc5_) != null)
         {
            _loc5_ = "none";
         }
         if(_loc1_.hasMedal(_loc7_))
         {
            _loc7_ = "none";
         }
         return {
            "PXP":_loc4_,
            "PGold":_loc3_,
            "Medals":_loc7_,
            "AXP":0,
            "Alien":_loc5_,
            "Item":_loc6_
         };
      }
      
      public function advanceBattle() : void
      {
         ++this._currentFight;
      }
      
      public function checkLastFightOver() : Boolean
      {
         return this._currentFight == this._battlesInfos.length;
      }
      
      public function setWatchIds(param1:Array) : void
      {
         this._tournamentWatchesIds = param1;
      }
      
      override public function getAIWatchId() : String
      {
         return String(this._tournamentWatchesIds[this._currentFight - 1]);
      }
      
      public function get tournamentFinished() : Boolean
      {
         return this._tournamentFinished;
      }
      
      public function set tournamentFinished(param1:Boolean) : void
      {
         this._tournamentFinished = param1;
      }
      
      override public function playMusic() : void
      {
         Sfx.FadeSound(Sfx.currentMusicPlaying);
         if(this._currentFight == this._battlesInfos.length)
         {
            Sfx.PlayMusic("MusicTournamentFinal");
         }
         else
         {
            Sfx.PlayMusic("MusicTournament");
         }
      }
   }
}

