%make it a bit more general input projection method. Able to handle cases
%including:
%1, atomic equality/inequality constraints
%2, their disjunctives
%3, many constraints.
%that is, (alw_[0,30]((throttle[t] == 0)or (brake[t] == 0))) should be
%given in the form of, th_u0 == 0 or br_u0 == 0 ... th_u4 == 0 or br_u4==0
%
% computeRange(): given a variable and its value, compute the range of another variable
% according to the constraint
%


classdef PracticalFP_Single < FalsificationProblem
    properties  
        cp
        constraints
        cons_size
        variables
        %lb
        %ub
        S
        resultx
    end
    
    
    methods
        
        function this = PracticalFP_Single(BrSet, phi, cons, s)
            this = this@FalsificationProblem(BrSet, phi);
            if isa(BrSet, 'BreachSimulinkSystem')
                this.cp = BrSet.InputGenerator.signalGenerators{1,1}.num_cp(1);
            end
            this.constraints  = cons;
            this.cons_size = numel(cons);
            this.variables = BrSet.GetSysVariables();
            this.S = s;
            this.resultx = [];
        end
               
        
        function fval = objective_wrapper(this, x)
            
            if this.stopping()==true
                fval = this.obj_best;
            else
            % calling actual objective function
                
                x_v = this.getx(x, 1);
                
                
                fval = this.objective_fn(x_v);
                
                if fval<0
                    
                    x_v
                    this.resultx = x_v;
                    
                end
                
                % logging and updating best
                this.LogX(x, fval);
                %this.count_sim = this.count_sim + 1;
                
                
                % update status
                if rem(this.nb_obj_eval,this.freq_update)==0
                    this.display_status();
                end
            end
            
            
        end
        
        function xl = getx(this, x, k)
            xl = x;
            
            %should get related variables, like indices in x
            
            if k > this.cons_size
                %xl = [xl x];
            else
                
                [~, idxs] = this.check(x, k);
                
               
                
                %xt = [x x];%assume happens between two variables
                if this.S(idxs(1))> this.S(idxs(2))
                    rg1 = this.constraints{k}.getRange(this.variables(idxs(1)), x(idxs(2)));
                    bd1 = [this.lb(idxs(1)) this.ub(idxs(1))];
                    v1 = x(idxs(1));
                    xl(idxs(1)) = rg1.getPropValue(bd1, v1);
                else
                    rg2 = this.constraints{k}.getRange(this.variables(idxs(2)), x(idxs(1)));
                    bd2 = [this.lb(idxs(2)) this.ub(idxs(2))];
                    v2 = x(idxs(2));
                    xl(idxs(2)) = rg2.getPropValue(bd2, v2);
                end
                xl = this.getx(xl, k + 1);
                %xl = [xl this.getx(xt(:,2) ,k + 1)];
                %end
            end
            
        end
        
        function [ok, idx] = check(this, x, k)
            [ok,idx] = this.constraints{k}.satisfy(x, this.variables);
        end
        

    end
    
    
end