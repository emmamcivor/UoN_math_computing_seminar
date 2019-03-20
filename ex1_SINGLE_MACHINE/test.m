% matlab file to test parallel is working 
% a and b are the parameters we feed into the simulations

function test(a,b)

% outputs of simulation
c=a+b;
d=a*b;

% save the ouputs to a file in test_save folder with parameters making up filename
fn_save=['test_GNU_parallel-a_',num2str(a),'-b_',num2str(b),'.mat'];
save(fn_save,'c','d')

% print to standard out which can be caught by GNU parallel
fprintf(1,"\n\n[DATA]%d,%d,%d,%d\n\n",a,b,c,d);

% I found that I had to exit matlab explicitly but this might not be the case for other languages
exit; 
end
