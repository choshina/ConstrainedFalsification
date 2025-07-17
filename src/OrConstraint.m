classdef OrConstraint < handle
    properties
        sub_constraint1
        sub_constraint2
    end
    
    methods
        function this = OrConstraint(sub1, sub2)
            this.sub_constraint1 = sub1;
            this.sub_constraint2 = sub2;
        end
        
        
        function rg = getRange(this, variable, other_value)
            rg1 = this.sub_constraint1.getRange(variable, other_value);
            rg2 = this.sub_constraint2.getRange(variable, other_value);
            rg = rg1.Disjunct(rg2);
        end
        
        function [ok, idx] = satisfy(this, x, vars)
            [ok1, idx] = this.sub_constraint1.satisfy(x, vars);
            ok2 = this.sub_constraint2.satisfy(x, vars);
            ok = ok1|ok2;
        end
    end
end