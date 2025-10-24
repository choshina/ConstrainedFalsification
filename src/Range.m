classdef Range < handle
    properties
        lb  % Lower bounds (1×n array)
        ub  % Upper bounds (1×n array)
        n   % Number of intervals
    end
    
    methods
        %% Constructor
        function this = Range(lb, ub)
            if nargin == 0
                this.lb = [];
                this.ub = [];
                this.n = 0;
                return;
            end
            
            if length(lb) ~= length(ub)
                error('lb and ub must have the same length.');
            end
            
            % Ensure lb <= ub for all intervals
            if any(lb > ub)
                error('Each lower bound must be <= the corresponding upper bound.');
            end
            
            % Sort by lower bounds
            [lb, idx] = sort(lb);
            ub = ub(idx);
            
            % Merge overlapping or adjacent intervals
            merged_lb = [];
            merged_ub = [];
            cur_lb = lb(1);
            cur_ub = ub(1);
            
            for i = 2:length(lb)
                if lb(i) <= cur_ub  % overlapping or adjacent
                    cur_ub = max(cur_ub, ub(i));
                else
                    merged_lb(end+1) = cur_lb; %#ok<AGROW>
                    merged_ub(end+1) = cur_ub; %#ok<AGROW>
                    cur_lb = lb(i);
                    cur_ub = ub(i);
                end
            end
            
            % Add the last interval
            merged_lb(end+1) = cur_lb;
            merged_ub(end+1) = cur_ub;
            
            this.lb = merged_lb;
            this.ub = merged_ub;
            this.n = length(merged_lb);
        end
        
        %% getPropValue
        function pv = getPropValue(this, bound, value)
            if length(bound) ~= 2
                error('bound must be a 2-element array [a, b].');
            end
            
            a = bound(1);
            b = bound(2);
            if value < a || value > b
                error('value must be within the given bound interval.');
            end
            
            % Normalize to [0,1] position
            pos = (value - a) / (b - a);
            
            % Compute total length of this range
            total_len = sum(this.ub - this.lb);
            target_pos = pos * total_len;
            
            % Find which subinterval contains the proportional value
            cum_len = cumsum(this.ub - this.lb);
            idx = find(target_pos <= cum_len, 1, 'first');
            if isempty(idx)
                idx = this.n;
            end
            
            % Position within the selected subinterval
            prev_len = 0;
            if idx > 1
                prev_len = cum_len(idx-1);
            end
            offset = target_pos - prev_len;
            pv = this.lb(idx) + offset;
        end
        
        %% Complement
        function rg = Complement(this)
            if isempty(this.lb)
                rg = Range(-Inf, Inf);
                return;
            end
            
            new_lb = [];
            new_ub = [];
            
            % Start from -Inf to first lb
            if this.lb(1) > -Inf
                new_lb(end+1) = -Inf;
                new_ub(end+1) = this.lb(1);
            end
            
            % Between intervals
            for i = 1:this.n-1
                new_lb(end+1) = this.ub(i);
                new_ub(end+1) = this.lb(i+1);
            end
            
            % Last interval to +Inf
            if this.ub(end) < Inf
                new_lb(end+1) = this.ub(end);
                new_ub(end+1) = Inf;
            end
            
            rg = Range(new_lb, new_ub);
        end
        
        %% Union
        function rg = Disjunct(this, other_rg)
            new_lb = [this.lb, other_rg.lb];
            new_ub = [this.ub, other_rg.ub];
            rg = Range(new_lb, new_ub);  % constructor will merge automatically
        end
        
        %% Intersection
        function rg = intersect(this, other_rg)
            new_lb = [];
            new_ub = [];
            
            for i = 1:this.n
                for j = 1:other_rg.n
                    l = max(this.lb(i), other_rg.lb(j));
                    u = min(this.ub(i), other_rg.ub(j));
                    if l < u
                        new_lb(end+1) = l; %#ok<AGROW>
                        new_ub(end+1) = u; %#ok<AGROW>
                    end
                end
            end
            
            if isempty(new_lb)
                rg = Range([], []);
            else
                rg = Range(new_lb, new_ub);
            end
        end
    end
end
