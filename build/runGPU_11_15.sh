#!/usr/bin/env bash
#SBATCH --job-name=11_15
#SBATCH --gres=gpu:4
#SBATCH --qos=qos_gpu-t4
#SBATCH --cpus-per-task=5
#SBATCH --output=/data1/GPU_11_15.out
#SBATCH --error=./errors/GPU_11_15.err
#SBATCH --time=200:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
srun time ./GPU_handle_11_15
