% matlab file to test parallel is working 
% a and b are the parameters we feed into the simulations

function test(a,b,c)

% outputs of simulation
d=a^2+b^2+c^2; 
e=a^3+b^3+c^3+d^3;

% save the outputs to a file in test_save folder with parameters making
% up filename
fn_save=['test_GNU_parallel-a_',num2str(a),'-b_',num2str(b),'-c_',num2str(c),'.mat'];
save(fn_save,'c','d','e')

% print to standard out which can be caught by GNU parallel
fprintf(1,"\n\n[DATA]%d,%d,%d,%d,%d\n\n",a,b,c,d,e);

% I found that I had to exit matlab explicitly but this might not be 
% the case for other languages
exit; 
end
