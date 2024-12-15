# Scalable Computation of Molecular Trajectory Analysis Using Apache Spark

This project demonstrates the use of Apache Spark for scalable and efficient post-processing of molecular dynamics (MD) simulation data. It focuses on calculating the **Mass Accommodation Coefficient (MAC)** to analyze phase change phenomena like evaporation and boiling.

## Features
- Parallel processing of large MD trajectory datasets using Apache PySpark.
- Performance benchmarking against sequential implementations.
- Handles datasets with periodic boundary conditions and large-scale molecule trajectories.

## Problem Statement
MD simulations generate vast datasets that require significant computational resources for post-processing. This project leverages Spark's distributed memory mechanism to reduce runtime and improve efficiency.

## Project Structure
- **Sequential Code**: A MATLAB implementation for baseline performance.
- **Parallel Code**: A PySpark implementation to process data efficiently.

## Results
- Achieved up to **4x speedup** in runtime with optimized code.
- Benchmarked performance on datasets up to 3 GB in size.

## Challenges
- Limited by the lack of an HDFS cluster and reliance on single-node Databricks Community Edition.

## How to Use
1. Clone the repository:  
   ```bash
   git clone https://github.com/swargo98/Scalable-Computation-of-Molecular-Trajectory-Analysis.git

2. Install dependencies
3. Fix the sbatch file to submit the job.
4. Submit the job with your trajectory data using:
    ```bash
   sbatch your_script.sbatch
