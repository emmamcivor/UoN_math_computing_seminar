function test(ARGS)
input1 = parse(Float64, ARGS[1])
input2 = parse(Float64, ARGS[2])
# outputs of simulation
c=input1+input2;
d=input1*input2;



# print to standard out which can be caught by GNU parallel
output = string(ARGS[1],",",ARGS[2],",",output1,",",output2,"\n")
print(output)

# I found that I had to exit matlab explicitly but this might not be 
# the case for other languages
end
