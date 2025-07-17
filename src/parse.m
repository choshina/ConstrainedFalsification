function constraints = parse(filename)

    constraints = {};
    fid = fopen(filename);
    line = fgetl(fid);
    num = str2num(line);
    for i = 1:num
       constraints{end + 1} = readConstraint(fid);
    end

end

function constraint = readConstraint(fid)
    line = fgetl(fid);
    switch line
        case 'eq'
            line = fgetl(fid);
            s = split(line, ' ');
            a = str2double(s{1});
            b = str2double(s{2});
            c = str2double(s{3});
            v1 = s{4};
            v2 = s{5};
            constraint = EqConstraint(a,b,c,v1,v2);
        case 'ine'
            line = fgetl(fid);
            s = split(line, ' ');
            a = str2double(s{1});
            b = str2double(s{2});
            c = str2double(s{3});
            v1 = s{4};
            v2 = s{5};
            constraint = IneConstraint(a,b,c,v1,v2);
        case 'neg'
            sub_constraint = readConstraint(fid);
            constraint = NegConstraint(sub_constraint);
        case 'or'
            sub_constraint1 = readConstraint(fid);
            sub_constraint2 = readConstraint(fid);
            constraint = OrConstraint(sub_constraint1, sub_constraint2);
        case 'and'
            sub_constraint1 = readConstraint(fid);
            sub_constraint2 = readConstraint(fid);
            constraint = AndConstraint(sub_constraint1, sub_constraint2);

    end
end