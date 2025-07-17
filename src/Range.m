%one-dimensional range

classdef Range<handle
    properties
        %NaN, [a,b], [-Inf, b], [a;b c;d]
        lb
        ub
        n
    end
    
    methods
        function this = Range(lb, ub)
            this.lb = lb;
            this.ub = ub;
            this.n = numel(lb);
            k = 1;
            sz = this.n;
            while sz> k && this.ub(k)>=this.lb(k+1)
                this.ub(k) = this.ub(k+1);
                this.lb(k+1) = [];
                this.ub(k+1) = [];
                sz = numel(this.lb);
            end
            if isnan(lb)
                this.n = 1;
            else
                this.n = numel(this.lb);
            end
        end
        
        %this object is a feasible range, bound is the hypercube bound,
        %value is a sampled value
        %the task is to find a proportional for value in the feasible area
        %
        %
        function pv = getPropValue(this, bound, value) %works only for convex case
                                                        %it can happen that
                                                        %there exist 2
                                                        %segments
            brg = Range(bound(1), bound(2));
            intsec = this.intersect(brg);
            if isnan(intsec.lb)
                
                pv = NaN;
            else       
                rat = (value - bound(1))/(bound(2)-bound(1));
                int_len = 0;
                for i = 1:numel(intsec.lb)
                    int_len = int_len + intsec.ub(i) - intsec.lb(i);
                end
                delta = rat*int_len;
                
                %sz = numel(intsec.lb);

                j = 1;
                seg_len = intsec.ub(1)-intsec.lb(1);
                while true 
                    
                    if delta> seg_len +  0.01 %for precision problem
                        j = j+ 1;
                        
                        
                        delta = delta-seg_len;
                        seg_len = intsec.ub(j)-intsec.lb(j);
                    else
                        break;
                    end
                    
                end
                pv = intsec.lb(j) + delta;
            end
        end
        
        
        
        
        
        
        
  %{       
        function rg = intersect(this, other_rg)
            n_this = this.Complement();
            
            n_other = other_rg.Complement();
            
            
            n_rg = n_this.Disjunct(n_other);
            rg = n_rg.Complement();
            
        end
       
        function rg = open(this)
            rg = Range(this.lb, this.ub);
            if isnan(rg.lb)
                
            else
                
                for i = 1:numel(rg.lb)
                    if rg.lb(i)~=-Inf
                        rg.lb(i) = rg.lb(i)-0.00000001;

                    end
                    if rg.ub(i)~=Inf
                        rg.ub(i) = rg.ub(i) + 0.00000001;
                    end
                end
            end
        end
        
        function rg = close(this)
            rg  = Range(this.lb, this.ub);
            if isnan(rg.lb)
               
            else
                for i  = 1:numel(rg.lb)
                    if rg.lb(i)~= -Inf && rg.lb(i) - floor(rg.lb(i)) < 0.0000001
                        rg.lb(i) = floor(rg.lb(i));
                    end
                    if rg.ub(i) ~= Inf && ceil(rg.ub(i)) - rg.ub(i) < 0.0000001
                        rg.ub(i) = ceil(rg.ub(i));
                    end
                end
            end
        end
  %}      
        function rg = Complement(this)
            this_rg = Range(this.lb, this.ub);
            %this_rgo = this_rg.open();
            if this_rg.n>1
                lb_ = [];
                ub_ = [];
                if this_rg.lb(1) ~= -Inf
                    lb_ = [lb_;-Inf];
                    ub_ = [ub_;this_rg.lb(1)];
                end
                for i = 1:this_rg.n-1
                    lb_ = [lb_;this_rg.ub(i)];
                    ub_ = [ub_;this_rg.lb(i+1)];
                end
                if this_rg.ub(end) ~= Inf
                    lb_ = [lb_;this_rg.ub(end)];
                    ub_ = [ub_;Inf];
                end
                rg_ = Range(lb_, ub_);

            else
                if isnan(this_rg.lb) %NaN is only possible when n = 1
                    rg_ = Range(-Inf, Inf);
                elseif this_rg.lb == -Inf
                    if this_rg.ub == Inf
                        rg_ = Range(NaN, NaN);
                    else
                        rg_ = Range(this_rg.ub, Inf);
                    end
                else
                    if this_rg.ub == Inf
                        
                        rg_ = Range(-Inf, this_rg.lb);
                    else
                        lb_ = [-Inf;this_rg.ub];
                        ub_ = [this_rg.lb;Inf];
                        rg_ = Range(lb_, ub_);
                    end
                end
                    
            end
            rg = rg_;
        end
      
        
        function rg = Disjunct(this, other_rg) %limited: lb>-99999999; ub<99999999
            lb_ = [];
            ub_ = [];
            idx1 = 1;
            idx2 = 1;
            status = 0;   %0: waiting for lb 1: waiting for ub 2:
            
            rg1 = this.preprocess();
            rg2 = other_rg.preprocess();
            
            
            
            if isnan(rg1.lb)
                rg = rg2.changeBack();
            elseif isnan(rg2.lb)
                rg = rg1.changeBack();
            else
                while true
                    if status == 0
                        if rg1.scan(idx1) <= rg2.scan(idx2)
                            lb_ = [lb_; rg1.scan(idx1)];
                            idx1 = idx1 + 1;
                        else
                            lb_ = [lb_; rg2.scan(idx2)];
                            idx2 = idx2 + 1;
                        end
                        status = status + 1;
                    elseif status == 1
                        if rg1.scan(idx1) <= rg2.scan(idx2)
                            if mod(idx1, 2) == 1
                                status = status + 1;
                            else
                                ub_ = [ub_;rg1.scan(idx1)];
                                status = status -1;
                            end
                            idx1 = idx1 + 1;
                        else
                            if mod(idx2, 2) == 1
                                status = status + 1;
                            else
                                ub_ = [ub_;rg2.scan(idx2)];
                                status = status -1;
                            end
                            idx2 = idx2 + 1;
                        end

                    else
                        if rg1.scan(idx1) <= rg2.scan(idx2)
                            idx1 = idx1 + 1;
                        else
                            idx2 = idx2 + 1;
                        end
                        status = status - 1;
                    end
                    if rg1.scan(idx1) ==Inf && rg2.scan(idx2)== Inf
                        break;
                    end

                end
                
                rg = Range(lb_, ub_).changeBack();
            end
        end
        
        function v = scan(this, i)%return i/2-th lb/ub
            if i <= 2*this.n
                if mod(i,2) == 0
                    v = this.ub(i/2);
                else
                    j = (i+1)/2;
                    v = this.lb(j);
                end
            else
                v = Inf;
            end
        end
        
        
        function rg = intersect(this, other_rg) %limited: lb>-99999999; ub<99999999
            lb_ = [];
            ub_ = [];
            idx1 = 1;
            idx2 = 1;
            status = 0;   %0: waiting for lb 1: waiting for ub 2:
            
            rg1 = this.preprocess();
            rg2 = other_rg.preprocess();
            
            
            
            if isnan(rg1.lb)
                rg = rg2.changeBack();
            elseif isnan(rg2.lb)
                rg = rg1.changeBack();
            else
                while true
                    if status == 0
                        if rg1.scan(idx1)<= rg2.scan(idx2)
                            
                            idx1 = idx1 + 1;
                        else
                            
                            idx2 = idx2 +1;
                        end
                        status = status + 1;
                    elseif status ==1
                        if rg1.scan(idx1) < rg2.scan(idx2)
                            if mod(idx1,2) == 1
                                status  = status + 1;
                                lb_ = [lb_;rg1.scan(idx1)];
                            else
                                status = status -1;
                            end
                            idx1 = idx1+ 1;
                        elseif rg1.scan(idx1) > rg2.scan(idx2)
                            if mod(idx2, 2) == 1
                                status = status + 1;
                                lb_ = [lb_; rg2.scan(idx2)];
                            else
                                status = status -1;
                            end
                            idx2 = idx2 + 1;
                        else
                            if mod(idx1,2) == 1 %idx1 odd, haven't started 
                                status = status + 1;
                                lb_ = [lb_;rg1.scan(idx1)];
                                idx1 = idx1 + 1;
                            else 
                                status = status + 1;
                                lb_ = [lb_;rg2.scan(idx2)];
                                idx2 = idx2 + 1;
                            end
                        end
                    else
                        if rg1.scan(idx1)<= rg2.scan(idx2)
                            ub_ = [ub_;rg1.scan(idx1)];
                            idx1 = idx1+1;
                        else
                            ub_ = [ub_;rg2.scan(idx2)];
                            idx2 = idx2 + 1;
                        end
                        status = status -1;
                    end
                    
                    if rg1.scan(idx1) ==Inf && rg2.scan(idx2)== Inf
                        break;
                    end
                end
                
                rg = Range(lb_, ub_).changeBack();
            end
            
            
        end
        
        function rg = preprocess(this)
            rg = Range(this.lb, this.ub);
            if isnan(rg.lb)
                
            else
                if this.lb(1) == -Inf
                    rg.lb(1) = -99999999;
                end
                if this.ub(end) == Inf
                    rg.ub(end) = 99999999;
                end
            end
        end
        
        function rg = changeBack(this)
            rg = Range(this.lb, this.ub);
            if isnan(rg.lb)
                
            else
                
                if this.lb(1) == -99999999
                    rg.lb(1) = -Inf;
                end
                if this.ub(end) == 99999999
                    rg.ub(end) = Inf;
                end
            end
        end
        
    end
    
end