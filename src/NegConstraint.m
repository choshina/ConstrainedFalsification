classdef NegConstraint<handle
    properties
        sub_constraint
    end
    
    methods
        function this = NegConstraint(sc)
            this.sub_constraint = sc;
        end
        
        function rg = getRange(this, variable, other_value)
            rg_ = this.sub_constraint.getRange(variable, other_value);
            rg = rg_.complement();
        end
        
        function [ok, idx] = satisfy(this, x, vars)
            [ok_n, idx] = this.sub_constraint.satisfy(x, vars);
            ok = ~ok_n;
            
        end
    end
end