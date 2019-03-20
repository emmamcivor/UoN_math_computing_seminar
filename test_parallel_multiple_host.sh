#!/usr/bin/bash

(parallel --joblog ./parallel.log --eta -sshdelay 5 --sshloginfile ./hostnames --resume --jobs 2 --load 75% --noswap --nice 5 --retries 3 --colsep ',' --arg-file parameters_5.txt run_test_matlab.sh {1} {2} & echo $! >&3 ) 3>$HOME/parallel.pid | tee parallel.out


