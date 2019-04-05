#!/usr/bin/env julia

input1 = parse(Float64, ARGS[1])
input2 = parse(Float64, ARGS[2])
# outputs of simulation
output1=input1+input2;
output2=input1*input2;

# print to standard out which can be caught by GNU parallel
#output = string(ARGS[1],",",ARGS[2],",",output1,",",output2,"\n")
using JLD2, FileIO
save("output_$(ARGS[1])_$(ARGS[2])_$(output1)_$(output2).jld2","output1",output1,"output2",output2)


