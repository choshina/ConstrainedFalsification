%the difference from the original one is that, the argument pattern is the
%set of the applicable S.
classdef PFPMAB2 < handle
    properties  
        BrSys
        phi
        cons
        
        budget
        budget_unit
        
        c
        
        %runtime variables
        machines
        ucbvalues
        counter
        
        %return information
        falsified
        num_sim

		time

        
        
        %pattern %e.g., 1111122222  <- '1234512345'
                % 0000012345 <- '0000011111'
        
        
    end
    
    
    methods
        
        function this = PFPMAB2(BrSys, phi, cons,  budget, b_u, c,  pattern)
            this.BrSys = BrSys;
            this.phi = phi;
            this.cons = cons;
            this.budget = budget;
            this.budget_unit = b_u;
            this.c = c;
            
            
            S_set = pattern;
            [s_size, ~] = size(S_set);
            for i = 1:s_size
                br = BrSys.copy();
                this.machines = [this.machines BanditMachine(br, phi, cons, S_set(i,:) ,b_u)];
                this.ucbvalues = [this.ucbvalues 0];
            end
            
            this.counter = 0;
            
            this.falsified = false;
            this.num_sim = 0;
			this.time = 0;
        end
               
        
        function solve(this)
            global max_robustness;
            
            max_robustness = 0;
            idx = 0;
            stop = false;
			tic
            for i = 1: numel(this.machines)
                this.machines(i).simulate();
                this.counter = this.counter + 1;
                if this.machines(i).stop_flag
                    stop = true;
                    this.falsified= 1;
					this.time  =  toc;
                    break;
                end
            end
            
            if stop
                
            else  
                while true
                    if this.checkstop()
                        break;
                    else
                        for j = 1:numel(this.machines)
                            this.ucbvalues(j) = this.UCB1(this.machines(j));
                            [~, idx] = max(this.ucbvalues);
                        end
                        this.machines(idx).simulate();
                        this.counter = this.counter + 1;
                    end
                end
            end
            
        end
        
        
        
        function stop = checkstop(this)
            stop = false;
			this.time = toc;
            for i = 1:numel(this.machines)
                if this.machines(i).stop_flag == true
                    stop = true;
					this.falsified = 1;
                    break;
                end
            end
			if this.time > this.budget + 10
				stop = true;
			end
        end
        
        function uv =  UCB1(this, umachine)
            uv = umachine.reward + this.c*sqrt((2.0*log(this.counter+1))/(umachine.visit+1));
        end
        
        
        function s_set = permute(this, pattern)
            s_set = [];
            
            idx = [];
            num = [];
            ct = 0;
            len = numel(pattern);
            for i = 1:len
                ele = str2double(pattern(i));
                if ele == 0
                    continue;
                elseif ele > ct
                    num = [num 1];
                    idx = [idx; i];
                    ct  = ct+ 1;
                else
                    num(ele) = num(ele) + 1;
                    idx(ele, num(ele)) = i;
                end
            end
            
            temp_set = zeros(1, len);
            for j = 1:numel(num)
                t_ = 1:num(j);
                per = this.permute_t(t_);
                [s,~] = size(per);
                [s_tmp,~] = size(temp_set);
                temp_set = repmat(temp_set, s ,1);
                
                for k = 1:s
                    %per(k,:)
                    %idx(j,:)
                    for u = 1:s_tmp
                        
                       % this.modify(idx(j,:), temp_set( (k-1)* s_tmp:k* s_tmp , :), per(k,:));
                       temp_set( s_tmp*(k-1) + u , idx(j,:)) = per(k,:); 
                    end
                end
            end
            
            s_set = temp_set;
        end
        
       
        
        
        
        function s_set = permute_t(this,ns)
            s_set = [];
            
            if numel(ns) == 1
                s_set = ns;
            else
                for i = 1:numel(ns)
                    ns_ = ns;
                    t = ns_(i);
                    ns_(i) = [];
                    sub_per = this.permute_t(ns_);
                    [sz,~] = size(sub_per);
                    newrows = [t*ones(sz, 1) sub_per];
                    %newrow = [t this.permute_t(ns_)];
                    
                    s_set = [s_set;newrows];
                end
            end
        end

    end
    
    
end
