#!/bin/bash
#SBATCH --job-name=spark_job_32       # Job name
#SBATCH --output=spark_job_32.out     # Output file
#SBATCH --error=spark_job_32.err      # Error file
#SBATCH --time=01:00:00            # Time limit hrs:min:sec
#SBATCH --ntasks=1                 # Number of tasks (typically 1 for Spark driver)
#SBATCH --cpus-per-task=32          # Number of CPUs per task
#SBATCH --mem=32G                   # Memory per node (adjust as needed)
#SBATCH --nodes=1                  # Number of nodes


# Set up Spark environment
export SPARK_HOME=/home/rs75c/Desktop/spark/spark-3.4.2-bin-hadoop3   # Update to your Spark installation directory
export PATH=$SPARK_HOME/bin:$PATH

# Print job details
echo "Job started on $(hostname) at $(date)"
echo "Using $SLURM_CPUS_PER_TASK CPUs"

# Run your Spark job
spark-submit --master local[$SLURM_CPUS_PER_TASK] /home/rs75c/Desktop/spark_python_code.py

# Print job completion
echo "Job finished at $(date)"