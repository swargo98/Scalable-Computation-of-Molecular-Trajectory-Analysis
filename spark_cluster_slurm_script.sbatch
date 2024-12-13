#!/bin/bash
#SBATCH --job-name=spark_job
#SBATCH --output=spark_job.out
#SBATCH --error=spark_job.err
#SBATCH --time=01:00:00
#SBATCH --nodes=4                 # Allocate 4 nodes
#SBATCH --ntasks=4                # 1 task per node
#SBATCH --cpus-per-task=16        # 16 CPUs per task
#SBATCH --mem=32G                 # Memory per node

# Load necessary modules or set environment variables
export SPARK_HOME=/home/rs75c/Desktop/spark/spark-3.4.2-bin-hadoop3
export PATH=$SPARK_HOME/bin:$PATH

# Get node hostnames
NODELIST=($(scontrol show hostnames $SLURM_JOB_NODELIST))
MASTER_NODE=${NODELIST[0]}  # The first node is the master
WORKER_NODES=(${NODELIST[@]:1})  # Remaining nodes are workers

# Start Spark master on the master node
if [ "$SLURM_PROCID" -eq 0 ]; then
    echo "Starting Spark master on $MASTER_NODE"
    $SPARK_HOME/sbin/start-master.sh --host $MASTER_NODE
fi

# Start Spark workers on worker nodes
if [ "$SLURM_PROCID" -ne 0 ]; then
    WORKER_NODE=${NODELIST[$SLURM_PROCID]}
    echo "Starting Spark worker on $WORKER_NODE"
    $SPARK_HOME/sbin/start-worker.sh spark://$MASTER_NODE:7077
fi

# Wait a bit to ensure master and workers are up
sleep 2

# Submit the Spark job from the master node
if [ "$SLURM_PROCID" -eq 0 ]; then
    echo "Submitting Spark job from master node $MASTER_NODE"
    spark-submit --master spark://$MASTER_NODE:7077 /home/rs75c/Desktop/spark_python_code.py
fi

# Wait for Spark job to finish
wait