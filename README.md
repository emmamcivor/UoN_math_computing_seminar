# Instructions for concurrently executing instances of a script (a basic example)
This page describes how I use [GNU parallel](https://www.gnu.org/software/parallel/) to execute instances of the script concurrently on multiple cores of a server. This is based on a page giving instructions for concurrently executing scripts by Anthony Hennessey. Unfortunately, this page is no longer available on the University workspace.

**Use Case**: Execute a processor intensive script multiple times with different inputs. Each execution of the script is independent of all other executions of the script.

*Further requirements*:
- we do not want to hog resources; we must share resources `nice` -ly. This reduces the priority of the processes. (UoN staff: this is described by the [considerate shared use of linux servers](https://workspace.nottingham.ac.uk/pages/viewpage.action?spaceKey=Maths&title=Considerate+shared+use+of+linux+servers) page)
- if the UNIX Systems Officer needs to stop our scripts it should be quick, simple and possible from a single machine
- if our scripts are stopped we should be able to restart from where we left off (once we have fixed the issue that resulted in it being

*Some further things we must do*:
- before we leave our handy work unattended let the UNIX Systems Officer know what you have done; just a quick email with details on how to stop it if it is causing a problem

## Things you may need to do before you start:
- install GNU Parallel locally if it is not available.
To check if it is available and in your PATH type:
```linux
which parallel
```
If not then update your PATH and MANPATH in your .bashrc file. Note that parallel needs to be available on all the machines as the central parallel uses the local parallel to determine number of CPUs (it is written in pure Perl so you can safely use the same copy everywhere)
```linux
export PATH=$HOME/local/bin:$PATH
export MANPATH=$HOME/local/share/man:$MANPATH
```
Fetch and install
```linux
mkdir -p $HOME/local/src
cd $HOME/local/src
wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
tar xvfj parallel-latest.tar.bz2
cd parallel-*
./configure --prefix=$HOME/local && make && make install
```
Reload your .bashrc file so that the PATH and MANPATH environment variables are updated
```linux
cd
. ./.bashrc
```
Now you can use parallel and read the documentation by typing 
```linux
man parallel
```

## The procedure
### Check the server status
You can use `top` to check the status of the server/machine you want to run multiple processes on

### Prepare some input files
I will assume you are in a `screen` session on one of the machines and want to run multiple instances of the (Matlab) script `test.m` concurrently on this machine.

We need the following files:

1. `test.m`

This is an example of a Matlab script that can be run in parallel. The script takes two input parameters (from the `parameters.txt` file) and does a simple operation on them, here it adds and multiplies them. Then we write the results of the operation (the `save` statement) to a unique file saved in this folder. The filename is constructed using the unique parameters and it is important not to write to the same file as processes might finish at different times and cause issues. The script also returns some summary information to `STDOUT` (the final print statement).

```Matlab
% matlab file to test parallel is working 
% a and b are the parameters we feed into the simulations

function test(a,b)

% outputs of simulation
c=a+b;
d=a*b;

% save the outputs to a file in test_save folder with parameters making
% up filename
fn_save=['test_GNU_parallel-a_',num2str(a),'-b_',num2str(b),'.mat'];
save(fn_save,'c','d')

% print to standard out which can be caught by GNU parallel
fprintf(1,"\n\n[DATA]%d,%d,%d,%d\n\n",a,b,c,d);

% I found that I had to exit matlab explicitly but this might not be 
% the case for other languages
exit; 
end
```

2. `parameters.txt`

The combinations of parameters needed for each run of `test.m` are in this file. There is one set of parameters per line; so in this
case we will be executing 5 instances of `test.m` .
```
1,2
3,4
5,6
7,8
9,10
```

3. `run_test_matlab.sh`

This shell script runs the Matlab script `test.m` and feeds in parameters `$1` and `$2` from (one line of) the parameter file.
```
#!/usr/bin/bash

matlab -nodisplay -nojvm -nosplash -nodesktop -r "test($1,$2)"
```

4. `test_parallel_1host.sh`

This shell script runs multiple instances of the Matlab script `test.m` simultaneously on one machine, according to the options given in the shell script. Specific explanation given below. This script obeys the fair use policy imposed on the servers in the School of Mathematical Sciences. GNU parallel can do much more (e.g. running multiple scripts across multiple remote machines) - read the `man` page and documentation. 

```perl
#!/usr/bin/bash

(parallel --joblog ./parallel.log --eta --resume --jobs 2 --load 75% --noswap --nice 5 --colsep ',' --arg-file parameters.txt run_test_matlab.sh {1} {2} & echo $! >&3 ) 3>$HOME/parallel.pid | tee parallel.out
```

#### Explanation of code
#### the bash shell bits
```
( $PARALLELCMD & echo $! >&3 ) 3>$HOME/parallel.pid | tee ./parallel.out
```
We need the `PID` of our parallel process just in case we need to kill it (and we do not want to have to grep the process list as this is
unreliable).
`$!` is a shell variable that captures the `PID` of the last command executed, but if we were to put that after the `tee` then it would capture the `PID` of the `tee` command and not parallel, so instead we write the `PID` to a file descriptor before piping to `tee` .

`STDOUT` from each execution of `test.m` will end up in `parallel.out`.

#### the parallel parameters
```
--joblog ./parallel.log
```
we can use the joblog to restart parallel if it is stopped (or killed for taking too much resource) by re-running with
the `--resume` option; the inputs to the script being parallel-ed must be the same but the parallel options can be adjusted
(similarly you can rerun scripts with an exit status that was not zero using --resume-failed)

```
--eta
```
give some progress stats

```
--jobs 2 --load 50% --noswap --nice 5
```
run a maximum of two jobs concurrently on each server, each with a nice value of 5

only start a new job if the load on the machine is less than 75% (considers the number of CPUs)

don't start jobs if the system is swapping


#### Making sure shell scripts are executable and accessible
Make sure the shell scripts (`run_test_matlab.sh` and `test_parallel_1host.sh`, which are needed to run GNU parallel) are in a folder which is on the local path in `.bashrc` so the scripts can be ran from any folder which contains your Matlab script and parameter file. 

If not; then suppose the scripts are in the folder `~/work/math_server_talks` and do the following:

```Linux
gedit ~/.bashrc
```
This opens a text editor so you can annotate the .bashrc file. Modify the `$PATH` to the following:

```Linux
export PATH=$HOME/local/bin:$HOME/work/math_server_talks:$PATH
```

and reload your .bashrc file so the PATH is updated tio allow `test_parallel_1host.sh` to be run directly on the command line.

#### Summary
1. Make sure the shell scripts are all executable (if not, make executable: `chmod u=wrx <filename.sh>`)
2. Make sure the shell scripts are in a folder which is on the local path. Check: type 
```Linux
test_parallel
```
on the command line and press 'tab' to complete the filename. If the file is on the local path then it will complete if not you need to modify the local path in the `.bashrc` file.

3. Make sure the working directory contains the `test.m` script and `parameters.txt` file. 

4. On the command line type 
```Linux
test_parallel_1host.sh
```
to run multiple instances of the `test.m` script in parallel. The saved files will be saved to the working directory which means you can keep everything together and have different folders for different parameter sets.


