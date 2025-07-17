classdef AndConstraint<handle
    properties
        sub_constraint1
        sub_constraint2
    end
    
    methods
        function this = AndConstraint(sub1, sub2)
            this.sub_constraint1 = sub1;
            this.sub_constraint2 = sub2;
        end
        
        function rg = getRange(this, variable, other_value)
            rg1 = this.sub_constraint1.getRange(variable, other_value);
            rg2 = this.sub_constraint2.getRange(variable, other_value);
            
            rg1c = rg1.Complement();
            rg2c = rg2.Complement();
            
            rg_c = rg1c.Disjunct(rg2c);
            rg = rg_c.Complement();
        end
            
        function [ok, idx] = satisfy(this, x, vars)
            [ok1, idx] = this.sub_constraint1.satisfy(x, vars);
            ok2 = this.sub_constraint2.satisfy(x, vars);
            ok = ok1&ok2;
        end
    end
    
end