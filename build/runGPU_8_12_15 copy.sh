#!/usr/bin/env bash
#SBATCH --job-name=5_9
#SBATCH --gres=gpu:1
#SBATCH --qos=qos_gpu-t4
#SBATCH --cpus-per-task=5
#SBATCH --output=/data1/vallee/GPU_5_9_all.out
#SBATCH --error=./errors/GPU_5_9_all.err
#SBATCH --time=200:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --ntasks-per-node=1
srun time ./5_9_all
