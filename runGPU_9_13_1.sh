#!/usr/bin/env bash
#SBATCH --job-name=GPU_test
#SBATCH --gres=gpu:1
#SBATCH --qos=qos_gpu-t4
#SBATCH --cpus-per-task=5
#SBATCH --output=/data1/GPU_9_13_1.out
#SBATCH --error=./errors/GPU_9_13_1.err
#SBATCH --time=30:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --ntasks-per-node=1
srun time ./GPU_handle_9_13_1
