#!/usr/bin/bash

(parallel --joblog ./parallel.log --eta --resume --jobs 2 --load 75% --noswap --nice 5 --colsep ',' --arg-file parameters.txt run_test_matlab_3params.sh {1} {2} {3} & echo $! >&3 ) 3>$HOME/parallel.pid | tee parallel.out
