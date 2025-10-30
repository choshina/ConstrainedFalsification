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


classdef PFPINF2 < FalsificationProblem
    properties  
        cp
        constraints
        cons_size
        variables
        %lb
        %ub
        S
    end
    
    
    methods
        
        function this = PFPINF2(BrSet, phi, cons, S)
            this = this@FalsificationProblem(BrSet, phi);
            if isa(BrSet, 'BreachSimulinkSystem')
                this.cp = BrSet.InputGenerator.signalGenerators{1,1}.num_cp(1);
            end
            this.constraints  = cons;
            this.cons_size = numel(cons);
            this.variables = BrSet.GetSysVariables();
            this.S = S;
        end
               
        
        function fval = objective_wrapper(this, x)
            
            if this.stopping()==true
                fval = this.obj_best;
            else
            % calling actual objective function
                
                rob_list = [];
                x_v = [];
                
                [ss, ~] = size(this.S);
                for i = 1:ss
                    s = this.S(i,:);
                    tx_v = this.getx(s,x, 1);
                    x_v = [x_v tx_v];
                end
                t_xv = unique(x_v', 'rows');
                x_v = t_xv';
                
                [~, b] = size(x_v);
                for j = 1:b
                    xn = x_v(:, j);
                    f = this.objective_fn(xn);
                    rob_list = [rob_list f];
                    if f<0
                        xn
                        break;
                    end
                end

                fval = min(rob_list);
                
                % logging and updating best
                this.LogX(x, fval);
                %this.count_sim = this.count_sim + 1;
                
                
                % update status
                if rem(this.nb_obj_eval,this.freq_update)==0
                    this.display_status();
                end
            end
            
            
        end
        
        function xl = getx(this, S, x, k)
            xl = x;
            
            %should get related variables, like indices in x
            
            if k > this.cons_size
                %xl = [xl x];
            else
                
                [~, idxs] = this.check(x, k);
                
               
                
                %xt = [x x];%assume happens between two variables
                if S(idxs(1))> S(idxs(2))
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
                xl = this.getx(S, xl, k + 1);
                %xl = [xl this.getx(xt(:,2) ,k + 1)];
                %end
            end
            
        end
        
        function [ok, idx] = check(this, x, k)
            [ok,idx] = this.constraints{k}.satisfy(x, this.variables);
        end
        

    end
    
    
end