% child class of FP for bandit machine, the main difference is that this
% class can resume a run of CMAES

classdef MABSingleFP < FalsificationProblem
    properties  
        cp
        constraints
        cons_size
        variables
        
        S
        
        maxIter
        mI_unit
        
        resultx
        best_robust
        
        resume_flag
    end
    
    
    methods
        
        function this = MABSingleFP(BrSet, phi, cons, s, mI)
            this = this@FalsificationProblem(BrSet, phi);
            if isa(BrSet, 'BreachSimulinkSystem')
                this.cp = BrSet.InputGenerator.signalGenerators{1,1}.num_cp(1);
            end
            this.constraints  = cons;
            this.cons_size = numel(cons);
            this.variables = BrSet.GetSysVariables();
            this.S = s;
            
            this.maxIter = 0;
            this.mI_unit = mI;
            
            this.resultx = [];
            
            this.resume_flag = false;
        end
        
        
        function res = solve(this)
            rfprintf_reset();
            
            % reset time
            this.ResetTimeSpent();
            
            % create problem structure
            problem = this.get_problem();
                        
            switch this.solver
                case 'init'
                    res = FevalInit(this);
                    
                case 'basic'
                    res = this.solve_basic();
                    
                case 'global_nelder_mead'
                    res = this.solve_global_nelder_mead();
                    
                case 'cmaes'
                    % adds a few more initial conditions
                    nb_more = 10*numel(this.params)- size(this.x0, 2);
                    if nb_more>inf
                        Px0 = CreateParamSet(this.BrSet.P, this.params,  [this.lb this.ub]);
                        Px0 = QuasiRefine(Px0, nb_more);
                        this.x0 = [this.x0' GetParam(Px0,this.params)]';
                    end
                    
                    this.maxIter = this.maxIter + this.mI_unit;
                    this.solver_options.StopIter = this.maxIter;
                    
                    
                    
                    file_suffix = num2str(this.S);
                    file_suffix = file_suffix(find(~isspace(file_suffix)));
                    this.solver_options.SaveFilename = strcat('variablescmaes_', file_suffix,'.mat');
                
                    
                    if this.resume_flag == false
                        this.solver_options.Resume = 0;
                        this.resume_flag = true;
                        %this.maxIter = 1;
                    else
                        this.solver_options.Resume = 1;
                        %this.maxIter = this.maxIter + this.mI_unit;
                    end
                    %this.solver_options.StopIter = this.maxIter;
                    
                    [x, fval, counteval, stopflag, out, bestever] = cmaes(this.objective, this.x0', [], this.solver_options);
                    
                    this.best_robust = bestever.f;
                   
                    
                    res = struct('x',x, 'fval',fval, 'counteval', counteval,  'stopflag', stopflag, 'out', out, 'bestever', bestever);
                    this.res=res;
		    
		    
                    
                case 'ga'
                    res = solve_ga(this, problem);
                    this.res = res;
                    
                case {'fmincon', 'fminsearch', 'simulannealbnd'}
                    [x,fval,exitflag,output] = feval(this.solver, problem);
                    res =struct('x',x,'fval',fval, 'exitflag', exitflag, 'output', output);
                    this.res=res;
                    
                case 'optimtool'
                    problem.solver = 'fmincon';
                    optimtool(problem);
                    res = [];
                    return;

                case 'binsearch'
                    res = solve_binsearch(this);
                    this.res = res;

                otherwise
                    res = feval(this.solver, problem);
                    this.res = res;
            end
            
            %this.DispResultMsg(); 
            
    
            
        end
               
        
        function fval = objective_wrapper(this, x)
            
            if this.stopping()==true
                fval = this.obj_best;
            else
            % calling actual objective function

                x_v = this.getx(x, 1);
                
                fval = this.objective_fn(x_v);
                
                if fval<0
                    x
                    x_v
                    this.resultx = x_v;
                    
                end

                % logging and updating best
                %this.LogX(x, fval);
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
                
                
                %if S_brake> S_throttle, hold brake and change throttle
                %if S_throttle> S_brake, hold throttle and change brake
                
                
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