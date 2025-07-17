classdef BanditMachine < handle
   properties
       robustness
       
       reward
       visit
       
       fal_problem
       budget_unit
       
       BrSys
       phi
       cons
       
       S
       
       stop_flag
       resultx
   end
   
   methods
       function this = BanditMachine(BrSys,phi, cons, s, b_u)
           this.BrSys = BrSys;
           this.phi = phi;
           this.cons = cons;
           this.S = s;
           
           
           this.reward = 0;
           this.visit = 0;
           this.robustness = intmax;
           
           this.budget_unit = b_u;
           
           this.fal_problem = MABSingleFP(BrSys, phi, cons, s, b_u);
           this.fal_problem.setup_solver('cmaes');
           
           %this.fal_problem.max_time = b_u;
           
           this.stop_flag = false;
           
           this.resultx = [];
       end
       
       
       function simulate(this)
           global max_robustness;
           this.fal_problem.solve();
           this.robustness = this.fal_problem.best_robust;
           
           if this.robustness > max_robustness
               max_robustness = this.robustness;
           end
           
           
           if this.robustness< 0
               this.stop_flag = true;
               this.resultx = this.fal_problem.resultx;
               this.resultx
           end
           
           this.visit = this.visit + 1;
           
           this.reward = 1- this.robustness/max_robustness;
 
           
           
          % report = ['sID:', num2str(this.S), '\n robustness:', num2str(this.robustness),  '\n visit:', num2str(this.visit), '\n MAX', num2str(max_robustness)];
          % disp(report);
       end
   end
end