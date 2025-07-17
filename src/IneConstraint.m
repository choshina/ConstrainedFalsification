classdef IneConstraint<handle
   
    properties
        a
        b
        c
        v1
        v2
    end
    
    methods
        function this = IneConstraint(a, b, c, v1, v2)
            this.a = a;
            this.b = b;
            this.c = c;
            this.v1 = v1;
            this.v2 = v2;
        end
        
        function rg = getRange(this, variable, other_value)
            if strcmp(variable, this.v1)
                if this.a > 0
                    v = (0- this.c - this.b*other_value)/this.a;
                    rg = Range(-Inf, v);
                elseif this.a<0
                    v = (0-this.c - this.b*other_value)/this.a;
                    rg = Range(v, Inf);
                elseif this.b*other_value + this.c <= 0
                    rg = Range(-Inf, Inf);
                else
                    rg = Range(NaN,NaN);
                end
            elseif strcmp(variable, this.v2)
                if this.b>0
                    v = (0- this.c - this.a*other_value)/this.b;
                    rg = Range(-Inf, v);
                elseif this.b<0
                    v = (0 - this.c - this.a*other_value)/this.b;
                    rg = Range(v, Inf);
                elseif this.a * other_value+ this.c<= 0
                    rg = Range(-Inf, Inf);
                else
                    rg = Range(NaN, NaN);
                end
            end
        end
        
        function [ok, idx] = satisfy(this, x, vars)
            idx_v1 = find(strcmp(vars, this.v1));
            idx_v2 = find(strcmp(vars, this.v2));
            ok = (this.a* x(idx_v1) + this.b*x(idx_v2) + this.c <= 0);
            idx = [idx_v1 idx_v2];
        end
        
        
        
    end
    
end