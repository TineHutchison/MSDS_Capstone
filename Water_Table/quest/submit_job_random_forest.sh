#!/bin/bash
#MSUB -A p30529
#MSUB -q normal
#MSUB -l walltime=12:00:00
#MSUB -m abe
#MSUB -M austinharrison2017@u.northwestern.edu
#MSUB -j oe
#MSUB -N random_forest
#MSUB -l nodes=1:ppn=4
#MSUB -l mem=6gb

# add a project directory to your PATH (if needed)
export PATH=$PATH:/projects/p30529/tools/

# load modules you need to use
module load python/anaconda3.6

# Set your working directory
cd $PBS_O_WORKDIR

# A command you actually want to execute:
python random_forest.py

# run this file with msub submit_job.sh
# might need to chmod u+x submit_job.sh


#showq -u <your_netID>	Shows your active jobs and their job numbers
#showq –w account = <your_allocation>	Shows your allocation’s active jobs and their job numbers
#checkjob <job_number>	
#Shows information about your specific job, including job status
#
#checkjob -v <job_number>	Detailed report from checkjob which is useful for debugging
#mjobctl -c <job_number>	Cancels your job from the command line
#mjobctl -c -w user=<your_netID> 	Cancels all of your jobs from the command line
