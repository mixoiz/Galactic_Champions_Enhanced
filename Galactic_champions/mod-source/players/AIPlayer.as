package players
{
   import battle.Battle;
   import battle.Tournament;
   import players.aliens.Alien;
   import players.aliens.AlienInfo;
   import players.effects.EffectsFactory;
   import players.items.Inventory;
   import players.items.Item;
   import players.skills.Skill;
   
   public class AIPlayer
   {
      
      private var _inventory:Inventory;
      
      private var _battle:Battle;
      
      private var _battleAliens:Vector.<Alien>;
      
      public function AIPlayer(param1:Battle)
      {
         super();
         this._battle = param1;
      }
      
      public function CreateInventory(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         this._inventory = new Inventory();
         if(param1 != "")
         {
            _loc2_ = param1.split(",");
            for each(_loc3_ in _loc2_)
            {
               this._inventory.AddItem(_loc3_);
            }
         }
      }
      
      public function CreateAliensForBattle(param1:Vector.<AlienInfo>) : Vector.<Alien>
      {
         var _loc2_:AlienInfo = null;
         this._battleAliens = new Vector.<Alien>();
         for each(_loc2_ in param1)
         {
            this._battleAliens.push(new Alien(2,_loc2_));
         }
         return this._battleAliens;
      }
      
      public function ChooseNextAlien() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Alien = null;
         var reserveBoss:Boolean = false;
         if(GameManager.Instance.tournamentSelectedID == "Tournament9" && GameManager.Instance.battleGame is Tournament && Tournament(GameManager.Instance.battleGame).getFightNumber() == 4)
         {
            for(var support:int = 0; support < 3; support++)
            {
               if(this._battleAliens[support].currentHp > 0) { reserveBoss = true; }
            }
         }
         _loc3_ = this._battle.GetPlayerAlien(2);
         _loc2_ = 0;
         _loc1_ = -1;
         while(_loc2_ < this._battleAliens.length && _loc1_ == -1)
         {
            if(this._battleAliens[_loc2_].currentHp > 0 && this._battleAliens[_loc2_] != _loc3_ && !(reserveBoss && _loc2_ == 3))
            {
               _loc1_ = _loc2_;
            }
            else
            {
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      public function ChooseAction() : void
      {
         var active:Alien = this._battle.GetPlayerAlien(2);
         var enemy:Alien = this._battle.GetPlayerAlien(1);
         var bestAttack:Skill = null;
         var healSkill:Skill = null;
         var rechargeSkill:Skill = null;
         var hpRatio:Number = active.currentHp / active.hp;
         var attackDamage:Number = 0;
         var basicDamage:Number = 0;
         var paralyzed:Boolean = this._battle.isActiveAlienAffectedByEffect(EffectsFactory.PARALYZE);
         var taunted:Boolean = this._battle.isActiveAlienAffectedByEffect(EffectsFactory.TAUNT);
         var trapped:Boolean = this._battle.isActiveAlienAffectedByEffect(EffectsFactory.TRAPPED);
         var attacks:Vector.<Skill> = active.SearchSkillsByType(Skill.ATTACK,active.currentMp);
         var i:int = 0;
         while(i < attacks.length)
         {
            var skill:Skill = attacks[i];
            if(bestAttack == null || skill.power > bestAttack.power)
            {
               bestAttack = skill;
            }
            i++;
         }
         var defenses:Vector.<Skill> = active.SearchSkillsByType(Skill.DEFENSE,active.currentMp);
         i = 0;
         while(i < defenses.length)
         {
            skill = defenses[i];
            if(skill.HasEffect(EffectsFactory.HEAL))
            {
               healSkill = skill;
            }
            if(skill.HasEffect(EffectsFactory.RECHARGE))
            {
               rechargeSkill = skill;
            }
            i++;
         }
         if(bestAttack != null)
         {
            attackDamage = active.totalStrength * ((1 + (active.level - 1) * 0.1) / enemy.totalDefense) * bestAttack.power;
            attackDamage *= (100 - enemy.damageReduction) / 100;
            if(attackDamage <= 0)
            {
               attackDamage = 1;
            }
         }
         i = 0;
         while(i < attacks.length)
         {
            skill = attacks[i];
            if(skill.mp_cost == 0)
            {
               basicDamage = active.totalStrength * ((1 + (active.level - 1) * 0.1) / enemy.totalDefense) * skill.power;
               basicDamage *= (100 - enemy.damageReduction) / 100;
               if(basicDamage <= 0)
               {
                  basicDamage = 1;
               }
               break;
            }
            i++;
         }
         if(!paralyzed && bestAttack != null && attackDamage >= enemy.currentHp)
         {
            this._battle.AlienUsedSkill(bestAttack);
            return;
         }
         if(!paralyzed && bestAttack != null && attackDamage * 2 >= enemy.currentHp)
         {
            this._battle.AlienUsedSkill(bestAttack);
            return;
         }
         if(hpRatio <= 0.2 && !trapped)
         {
            var nextAlien:int = this.ChooseNextAlien();
            if(nextAlien != -1)
            {
               this._battle.SwapAlien(2,nextAlien);
               return;
            }
         }
         if(hpRatio <= 0.45 && !taunted && healSkill != null)
         {
            this._battle.AlienUsedSkill(healSkill);
            return;
         }
         if(!taunted && rechargeSkill != null && active.currentMp < active.mp && (bestAttack == null || bestAttack.mp_cost == 0))
         {
            this._battle.AlienUsedSkill(rechargeSkill);
            return;
         }
         if(!paralyzed && bestAttack != null)
         {
            this._battle.AlienUsedSkill(bestAttack);
            return;
         }
         if(!trapped)
         {
            nextAlien = this.ChooseNextAlien();
            if(nextAlien != -1)
            {
               this._battle.SwapAlien(2,nextAlien);
            }
         }
      }
      
      private function GetRandomItem() : Item
      {
         var _loc1_:Item = null;
         if(this._inventory.items.length > 0)
         {
            return this._inventory.items[Math.ceil(Math.random() * this._inventory.items.length) - 1];
         }
         return _loc1_;
      }
      
      public function get inventory() : Inventory
      {
         return this._inventory;
      }
      
      public function Destroy() : void
      {
         var _loc1_:Alien = null;
         this._inventory = null;
         this._battle = null;
         for each(_loc1_ in this._battleAliens)
         {
            _loc1_.Destroy();
         }
         this._battleAliens = null;
      }
   }
}

