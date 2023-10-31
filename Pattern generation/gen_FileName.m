function [file_name] = gen_FileName(original_Name)
    c = clock;
    c = fix(c);
    temp = string('');
    for i = 2:6
       temp = temp + string('_') + string(c(i));
    end
    file_name = original_Name + temp + string(".png");
end
